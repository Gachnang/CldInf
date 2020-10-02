import logging
from jinja2 import Environment, FileSystemLoader

from helpers import restconf


class SwitchConfigurator:
    __JINJA_ENV = Environment(loader=FileSystemLoader("templates/"), trim_blocks=True, lstrip_blocks=True)

    def __init__(self, device_settings: dict, dry_run: bool = False):
        self.__device_settings = device_settings
        self.__logger = logging.getLogger('restconf')
        self.__logger.debug(f'Settings loaded: {device_settings}')
        self.__DRY_RUN = dry_run

    def __commit(self, resource: str, request: str):
        base_url = f'https://{self.__device_settings["address"]}/restconf/data/Cisco-IOS-XE-native:native/'
        if self.__DRY_RUN:
            print(f'XML for {base_url}{resource} \n {request} \n')
        else:
            restconf_helper = restconf.RestconfRequestHelper(self.__device_settings['username'],
                                                             self.__device_settings['password'],
                                                             base_url)
            restconf_helper.put(resource, body=request)

    def __get_template(self, file: str) -> str:
        return self.__JINJA_ENV.get_template(file)

    def __setup_loopback(self, loopback_id: int, address: str, mask: str, description: str):
        self.__logger.info(f'Setup loopback interface {loopback_id}')
        template = self.__get_template('loopback.jinja2')
        request_body = template.render(
            {'description': description, 'name': loopback_id, 'address': address, 'mask': mask})
        self.__commit(f'interface/Loopback={loopback_id}', request_body)

    def setup_hostname(self):
        hostname = self.__device_settings['hostname']
        self.__logger.info(f'Setup hostname {hostname}')
        template = self.__get_template('hostname.jinja2')
        request_body = template.render({'hostname': hostname})
        self.__commit('hostname', request_body)

    def setup_domain(self):
        domain = self.__device_settings['domain']
        dns_lookup = 'true' if self.__device_settings['dns_lookup'] else 'false'
        self.__logger.info(f'Setup domain {domain}')
        template = self.__get_template('domain.jinja2')
        request_body = template.render({'dns_lookup': dns_lookup, 'domain': domain})
        self.__commit('/ip/domain', request_body)

    def setup_loopbacks(self):
        loopbacks = self.__device_settings['interfaces']['loopbacks']
        for loopback in loopbacks:
            address = loopbacks[loopback]['address']
            mask = loopbacks[loopback]['mask']
            description = loopbacks[loopback]['description']
            self.__setup_loopback(loopback, address, mask, description)

    def setup_ospf(self):
        self.__logger.info("Setup OSPF")
        template = self.__get_template('ospf.jinja2')
        process_id = self.__device_settings['routing']['ospf']['process_id']
        request_body = template.render({'process_id': process_id,
                                        'networks': self.__device_settings['routing']['ospf']['networks']})
        self.__commit(f'router/ospf={process_id}', request_body)

    def setup_bgp(self):
        self.__logger.info("Setup BGP")
        template = self.__get_template('bgp.jinja2')
        as_number = self.__device_settings['routing']['bgp']['as_number']
        request_body = template.render(
            {'as_number': as_number,
             'networks': self.__device_settings['routing']['bgp']['networks'],
             'neighbors': self.__device_settings['routing']['bgp']['neighbors']})
        self.__commit(f'router/bgp={as_number}', request_body)
