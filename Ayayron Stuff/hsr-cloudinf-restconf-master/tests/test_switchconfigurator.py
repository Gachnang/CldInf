import pytest
import requests_mock
from requests import HTTPError
import sys

from deployment.deployment import SwitchConfigurator


@pytest.fixture
def base_url():
    return 'https://test.example/restconf/data/Cisco-IOS-XE-native:native/'


@pytest.fixture
def switch_configurator():
    device_settings = {
        'hostname': 'Test',
        'username': 'python',
        'password': 'cisco',
        'address': '127.0.0.1'
    }
    return SwitchConfigurator(device_settings=device_settings, dry_run=True)


def test_setup_hostname_correct_rendering(capsys, switch_configurator):
    switch_configurator.setup_hostname()
    out, err = capsys.readouterr()
    actual = "".join(out.split())
    expected = "".join(("""
                    XML for https://127.0.0.1/restconf/data/Cisco-IOS-XE-native:native/hostname
                    <hostname xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native" 
                    xmlns:ios="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
                    Test
                    </hostname>
                    
                    """).split())
    assert actual == expected

