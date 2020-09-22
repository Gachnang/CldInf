#!/bin/bash

setup_hostname()
{
    echo "Set hostname to $1"
    echo "$1" > '/etc/hostname'
    hostname $1
}

setup_ip()
{
    echo "Setup netplan"
    cat <<EOF > '/etc/netplan/50-cloud-init.yaml'
# This file is generated from information provided by $0
# Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
EOF
    if [ $# -ge "1" ]; then
        echo " ens2 = $1"
        cat <<EOF >> '/etc/netplan/50-cloud-init.yaml'

        ens2:
            dhcp4: false
            addresses: [$1]
EOF
    fi
    if [ $# -ge "2" ]; then
        echo " ens3 = $2"
        cat <<EOF >> '/etc/netplan/50-cloud-init.yaml'

        ens3:
            dhcp4: false
            addresses: [$2]
EOF
    fi
    if [ $# -ge "3" ]; then
        echo " ens4 = $3"
        cat <<EOF >> '/etc/netplan/50-cloud-init.yaml'

        ens4:
            dhcp4: false
            addresses: [$3]
EOF
    fi
    netplan apply
}


echo "CldInf Networker"
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
  elif [ $# -lt "1" ]; then
    echo "Usage: $0 <name>"
    echo " name = Client, MITM, [R1 .. R5]"
    exit 1
  else
    echo "Start setup for '$1'"
    case $1 in
        Client)
            setup_hostname "Client"
            setup_ip "172.16.0.1/24"
            ;;
         *)
            echo "name is unknewn..."
            exit 1
            ;;
    esac
fi
