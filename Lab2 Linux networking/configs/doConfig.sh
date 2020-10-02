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
        ifconfig ens2 down
        echo " ens2 = $1"
        cat <<EOF >> '/etc/netplan/50-cloud-init.yaml'
        ens2:
            dhcp4: false
            addresses: [$1]
EOF
    fi
    if [ $# -ge "2" ]; then
        ifconfig ens3 down
        echo " ens3 = $2"
        cat <<EOF >> '/etc/netplan/50-cloud-init.yaml'
        ens3:
            dhcp4: false
            addresses: [$2]
EOF
    fi
    if [ $# -ge "3" ]; then
        ifconfig ens4 down
        echo " ens4 = $3"
        cat <<EOF >> '/etc/netplan/50-cloud-init.yaml'
        ens4:
            dhcp4: false
            addresses: [$3]
EOF
    fi
    
    netplan apply
    
    if [ $# -ge "1" ]; then
        ifconfig ens2 up
    fi
    if [ $# -ge "2" ]; then
        ifconfig ens3 up
    fi
    if [ $# -ge "3" ]; then
        ifconfig ens4 up
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

# log "/var/log/bird.log" all; # Log all in logfile: Commented out because af access error..
log syslog { info, remote, warning, error, auth, fatal, bug };

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
#    import none;    # Default is import all
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
        if [ "$var" != "$1" ] && [ "$var" != "$2" ]; then
            echo "        route $var;" >> '/etc/bird/bird.conf'
        fi
    done
    
    cat <<EOF >> '/etc/bird/bird.conf'
}

protocol ospf {
    tick 5;       # The routing table calculation and clean-up of areas' databases is not performed when a single link
                    # state change arrives. To lower the CPU utilization, it's processed later at periodical intervals of num
                    # seconds. The default value is 1.
    import all;
    #export filter {
    #        ospf_metric1 = 1000;
    #        if source = RTS_STATIC then accept; else reject;
    #};

    area 0 {
        networks {
            10.0.0.0/8;
            172.16.0.0/24;
            192.168.1.0/24;
        };
        
        interface "$2" {
            cost 10;
            type broadcast;
            hello 9; 
            retransmit 6; 
            wait 50; 
            dead 5;
        };

        interface "*" {
                cost 1000;
                stub;
        };
    };
}

EOF
    sysctl net.ipv4.ip_forward=1
    ip route flush table main
    bird -p
    birdc down
    # bird -R
    systemctl start bird
    birdc show status
    systemctl status bird
}

setup_firewall()
{
    nft add rule ip filter input ip saddr . ip daddr { 172.16.0.0/24 . 192.168.1.0/24 } counter accept
    echo "Setup firewall"
    cat <<EOF > '/etc/nftables.conf'
#!/usr/sbin/nft -f
# This file is generated from information provided by $0

flush ruleset

# ----- IPv4 -----
table ip filter {
	chain input {
		type filter hook input priority 0; policy accept;
	}

	chain forward {
		type filter hook forward priority 0; policy drop;
        ip saddr 192.168.1.0/24 ip daddr 172.16.0.0/24 accept comment "accept everything from 192.168.1.0/24 to 172.16.0.0/24"
        ip saddr 172.16.0.0/24 ip daddr 192.168.1.0/24 tcp dport 8080 accept comment "accept from 172.16.0.0/24 to 172.16.0.0/24:8080"
        ip protocol icmp drop comment "drop all ICMP types"
	}

	chain output {
		type filter hook output priority 0; policy accept;
	}
}

EOF
    nft -f /etc/nftables.conf
}

setup_MITM() 
{
    cat <<EOF > '/home/ins/injection.py'
from mitmproxy import http


def response(flow: http.HTTPFlow) -> None:
flow.response.content = ''<h1>Injected</h1><div>Injected by MITM!</div>''.encode(''utf-8'')
EOF
}

setup()
{
    echo "Start setup for '$1'"
    case $1 in
        Client)
            setup_hostname "Client"
            setup_ip "172.16.0.2/24"
            echo "            gateway4: 172.16.0.1" >> '/etc/netplan/50-cloud-init.yaml'
            ;;
        MITM)
            setup_hostname "MITM"
            setup_ip "10.0.100.2/24"
            echo "            gateway4: 10.0.100.1" >> '/etc/netplan/50-cloud-init.yaml'
            setup_MITM
            ;;
        R1)
            setup_hostname "R1"
            setup_ip "172.16.0.1/24" "10.0.1.1/24"
            setup_bird "1.1.1.1" "ens3" "172.16.0.0/24 via \"ens2\""
            # "10.0.0.0/8 via \"ens3\"" 
            ;;
        R2)
            setup_hostname "R2"
            setup_ip "10.0.1.2/24" "10.0.4.1/24" "10.0.2.1/24"
            setup_bird "2.2.2.2" "ens*" 
            # "10.0.1.0/24 via \"ens2\"" "10.0.4.0/24 via \"ens3\"" "10.0.3.0/24 via \"ens4\""
            ;;
        R3)
            setup_hostname "R3"
            setup_ip "10.0.2.2/24" "10.0.5.1/24" "10.0.3.1/24"
            setup_bird "3.3.3.3" "ens*" 
            #"10.0.2.0/24 via \"ens2\"" "10.0.4.0/24 via \"ens3\"" "10.0.5.0/24 via \"ens4\""
            ;;
        R4)
            setup_hostname "R4"
            setup_ip "10.0.4.2/24" "10.0.5.2/24" "10.0.100.1/24"
            setup_bird "4.4.4.4" "ens*" 
            ;;
        R5)
            setup_hostname "R5"
            setup_ip "10.0.3.2/24" "192.168.1.1/24"
            setup_bird "5.5.5.5" "ens2" "192.168.1.0/24 via \"ens3\""
            # "10.0.0.0/8 via \"ens2\""
            setup_firewall
            ;;
        *)
            echo "name is unknewn..."
            exit 1
            ;;
    esac
}

echo "CldInf Networker"
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
  elif [ $# -lt "1" ]; then
    hostname=$(hostname)
    case $hostname in
        Client|MITM|R1|R2|R3|R4|R5)
            setup $hostname
            ;;
        *)             
            echo "Usage: $0 <name>"
            echo " name = Client, MITM, [R1 .. R5]"
            exit 1
            ;;
    esac
  else
    setup $1
fi
