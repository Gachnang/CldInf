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
}

setup_bird() 
{
    echo "Setup bird"
    cat <<EOF > '/etc/bird/bird.conf'
# This file is generated from information provided by $0
# Please refer to the documentation in the bird-doc package or BIRD User's
# Guide on http://bird.network.cz/ for more information on configuring BIRD and
# adding routing protocols.

# Change this into your BIRD router ID.
router id $1;

# The Device protocol is not a real routing protocol. It doesn't generate any
# routes and it only serves as a module for getting information about network
# interfaces from the kernel.
protocol device {
    scan time 10; # Scan interfaces every 10 seconds
}

# The Kernel protocol is not a real routing protocol. Instead of communicating
# with other routers in the network, it performs synchronization of BIRD's
# routing tables with the OS kernel.
protocol kernel {
    metric 64;      # Use explicit kernel route metric to avoid collisions
                    # with non-BIRD routes in the kernel routing table
    persist;        # Don't remove routes on BIRD shutdown
    scan time 20;   # Scan kernel routing table every 20 seconds
    import none;
    export all;     # Actually insert routes into the kernel routing table
}


protocol rip {
    export all;
    import all;
    interface "*";
}

protocol static {
        import all;

EOF
    
    for var in "$@"
    do
        echo " $var"
        if [ "$var" != "$1" ]; then
            echo "        route $var;" >> '/etc/bird/bird.conf'
        fi
    done
    
    cat <<EOF >> '/etc/bird/bird.conf'
}

protocol ospf {
    tick 10;       # The routing table calculation and clean-up of areas' databases is not performed when a single link
                    # state change arrives. To lower the CPU utilization, it's processed later at periodical intervals of num
                    # seconds. The default value is 1.
    import all;
    export filter {
            ospf_metric1 = 1000;
            if source = RTS_STATIC then accept; else reject;
    };

    area 0 {
        interface "ens*" {
            cost 5;
            type pointopoint;
            hello 5; retransmit 2; wait 10; dead 20;

        };

        interface "*" {
                cost 1000;
                stub;
        };
    };
}

EOF
    
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
            setup_ip "172.16.0.2/24"
            echo "            gateway4: 172.16.0.1" >> '/etc/netplan/50-cloud-init.yaml'
            ;;
        MITM)
            setup_hostname "MITM"
            setup_ip "10.0.100.2"
            echo "            gateway4: 10.0.4.4" >> '/etc/netplan/50-cloud-init.yaml'
            ;;
        R1)
            setup_hostname "R1"
            setup_ip "172.16.0.1/24" "10.0.1.3/8"
            setup_bird "1.1.1.1" "10.0.0.0/16 via 10.0.2.2"
            ;;
        R2)
            setup_hostname "R2"
            setup_ip "10.0.2.2/8" "10.0.2.3/8" "10.0.2.4/8"
            setup_bird "2.2.2.2" "172.16.0.0/24 via 10.0.1.3" "10.0.1.0/24 via 10.0.1.3" "10.0.3.0/24 via 10.0.3.2" "10.0.4.0/24 via 10.0.4.2"
            ;;
        R3)
            setup_hostname "R3"
            setup_ip "10.0.3.2/8" "10.0.3.3/8" "10.0.3.4/8"
            setup_bird "3.3.3.3" 
            ;;
        R4)
            setup_hostname "R4"
            setup_ip "10.0.4.2/8" "10.0.4.3/8" "10.0.4.4/8"
            ;;
        R5)
            setup_hostname "R5"
            setup_ip "10.0.5.2/8" "192.168.1.1/24"
            ;;
        *)
            echo "name is unknewn..."
            exit 1
            ;;
    esac
    netplan apply
fi
