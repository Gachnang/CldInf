import pytest
import requests_mock
from requests import HTTPError

from helpers.restconf import RestconfRequestHelper, RestconfFormat


@pytest.fixture
def base_url():
    return 'https://test.example/restconf/data/Cisco-IOS-XE-native:native/'

@pytest.fixture
def url_resource():
    return 'test/'

@pytest.fixture
def restconf_helper():
    return RestconfRequestHelper('test',
                                 'test',
                                 'https://test.example/restconf/data/Cisco-IOS-XE-native:native/')

def test_get_xml_headers_without_additional_headers(restconf_helper):

    composite_headers = restconf_helper.get_headers(format=RestconfFormat.XML, headers=None,
                                                             )
    assert composite_headers == {'Content-Type': 'application/yang-data+xml',
                                 'Accept': 'application/yang-data+xml, application/yang-data.errors+xml'}


def test_get_json_headers_without_additional_headers(restconf_helper):
    composite_headers = restconf_helper.get_headers(format=RestconfFormat.JSON, headers=None)
    assert composite_headers == {'Content-Type': 'application/yang-data+json',
                                 'Accept': 'application/yang-data+json, application/yang-data.errors+json'}


def test_get_headers_with_additional_headers_contains_additional_header(restconf_helper):
    composite_headers = restconf_helper.get_headers(format=RestconfFormat.XML,
                                                            headers={'some_header': 'test_value'})
    assert composite_headers['some_header'] == 'test_value'


def test_get_xml_headers_with_additional_headers_contains_base_header(restconf_helper):
    composite_headers = restconf_helper.get_headers(format=RestconfFormat.XML,
                                                            headers={'some_header': 'test_value'})
    assert composite_headers['Content-Type'] == 'application/yang-data+xml'
    assert composite_headers['Accept'] == 'application/yang-data+xml, application/yang-data.errors+xml'


def test_get_json_headers_with_additional_headers_contains_base_header(restconf_helper):
    composite_headers = restconf_helper.get_headers(format=RestconfFormat.JSON,
                                                            headers={'some_header': 'test_value'})
    assert composite_headers['Content-Type'] == 'application/yang-data+json'
    assert composite_headers['Accept'] == 'application/yang-data+json, application/yang-data.errors+json'


def test_get_dispatches_request(base_url, restconf_helper, url_resource):
    with requests_mock.Mocker() as m:
        m.get(base_url + url_resource, text='test_response')
        response = restconf_helper.get(url_resource=url_resource)
        assert response == 'test_response'


def test_get_sets_headers(base_url, restconf_helper, url_resource):
    with requests_mock.Mocker() as m:
        m.get(base_url + url_resource, text='test_response', request_headers=RestconfRequestHelper.headers_xml)
        response = restconf_helper.get(url_resource=url_resource,
                                               restconf_format=RestconfFormat.XML)
        assert response == 'test_response'


def test_get_raises_exception(base_url, restconf_helper, url_resource):
    with pytest.raises(HTTPError):
        with requests_mock.Mocker() as m:
            m.get(base_url + url_resource, status_code=400, text='test_response',
                  request_headers=RestconfRequestHelper.headers_xml)
            response = restconf_helper.get(url_resource=url_resource,
                                                   restconf_format=RestconfFormat.XML)

def test_put_dispatches_request(base_url, restconf_helper, url_resource):
    with requests_mock.Mocker() as m:
        m.put(base_url + url_resource, text='test_response')
        response = restconf_helper.put(url_resource=url_resource, body='')
        assert response == 'test_response'

def test_put_sets_headers(base_url, restconf_helper, url_resource):
    with requests_mock.Mocker() as m:
        m.put(base_url + url_resource, text='test_response', request_headers=RestconfRequestHelper.headers_xml)
        response = restconf_helper.put(url_resource=url_resource,
                                               restconf_format=RestconfFormat.XML, body='')
        assert response == 'test_response'

def test_put_raises_exception(base_url, restconf_helper, url_resource):
    with pytest.raises(HTTPError):
        with requests_mock.Mocker() as m:
            m.put(base_url + url_resource, status_code=400, text='test_response',
                  request_headers=RestconfRequestHelper.headers_xml)
            response = restconf_helper.put(url_resource=url_resource,
                                                   restconf_format=RestconfFormat.XML, body='')