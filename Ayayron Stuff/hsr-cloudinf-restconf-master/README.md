# CloudInf Restconf Deployment

## Prerequirements & installation
- Python > 3.6
- pip
- Install the required libraries by running the command `pip install -r requirements.txt`

## Features
This tool is able to setup the following config sections of switches:
* Hostname
* Loopbacks (flexible count)
* Descriptions of interfaces
* OSPF (One process with flexible count of networks) 
* BGP (One AS with flexible count of networks and neighbors) 
* Support for Dry/test run (Just print rendered XMLs to console without deploying it to the physical device)

## ToDos
* [x] Setup Hostname
* [x] Setup Loopback 
* [x] Setup OSPF
* [x] Setup BGP
* [x] Possibility to deploy slightly different configuration(e.g. additional neighbor ships with other groups) with as little changes to the tool as possible
    * [x] Split Settings in smaller parts
    * [x] Make device config more general (No exercise like structure)
    * [x] Support definition of bgp/ospf neighbors/networks
* [x] Support description
* [x] Support DNS Domain route
* [x] Code documentation
* [x] Testing

## Usage
Update device_infos.yaml. For new deployments you can use device_infos_default.yaml (usage is documented within the file) and adjust it to your needs.

Deploy the configuration:
`python main.py`

Dry run (Prints changes to the cli without applying):
`python main.py --dry-run`

Debug mode:
`python main.py --dry-run`

## Documentation of the exercise
* Tried using self created JSON configuration (based on the Cisco DevNet and Github documentation) 
* Debugged Config trough Postman
* Setup switch manually via CLI and exported final config (See: docs/)
* Update code to reflect deployment of final config
* Use jinja templates
* Split config files in smaller parts for higher reusability
* Make code and device config more flexible to support more deployment scenrios
* Add support for additional device configs
* Add support for debug/dry run mode
* Documented code
* Added tests

### Test working setup
```bash
ping 10.0.1.1 source 192.168.3.1
```

## Code documentation
* main.py: Entrypoint, which checks arguments, sets up logging and includes the general workflow for the setup.
* deployment: Includes program code. This is split into a custom module for future modularity.
* deployment.deployment.SwitchConfigurator(): Class for Switch configuration. Includes all switch configuration logic, depends on the devvice_infos.yaml
* helpers: Includes helper classes
* helpers.restconf.RestconfRequestHelper(): Given class from the exercises, responsible for communication trough Restconf. Extended with PUT ability.
* templates/: Includes all jinja templates for deployment.
* docs/: Includes XML files from the reverse engineering process
* tests/: Includes tests for the application

