import argparse
import logging

from deployment import deployment
from typing import List
import yaml

logger = logging.getLogger('restconf')


def init_logger(debug=False):
    if debug:
        logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    ch.setFormatter(formatter)
    logger.addHandler(ch)


def load_devices() -> List[dict]:
    with open('device_infos.yaml', 'r') as host_file:
        hosts = yaml.load(host_file.read(), Loader=yaml.FullLoader)
        return hosts


def main(dry_run: bool = False):
    devices = load_devices()
    for device in devices:
        hostname = device['hostname']
        logger.info(f'Deployment started for {hostname}')
        configurator = deployment.SwitchConfigurator(device, dry_run)
        configurator.setup_hostname()
        configurator.setup_domain()
        configurator.setup_loopbacks()
        configurator.setup_ospf()
        configurator.setup_bgp()
        logger.info(f'Deployment finished for {hostname}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Mass-deploy switches.')
    parser.add_argument('--debug', dest='debug', default=False, action='store_true',
                        help='Enable debug mode (default: off)')
    parser.add_argument('--dry-run', dest='dry_run', default=False, action='store_true',
                        help='Enable dry run (default: off)')
    args = parser.parse_args()
    init_logger(args.debug)
    main(args.dry_run)
