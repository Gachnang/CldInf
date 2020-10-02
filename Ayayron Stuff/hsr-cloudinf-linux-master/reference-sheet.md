| command        | description |
| ------------- |:-------------:|
| hostnamectl set-hostname HOSTNAME      | Set the hostname of a system|
| netplan apply      | Apply settings configured in /etc/netplan/50-cloud-init.yaml (and any other files netplan gets its settings)|
| ip addr show INTERFACE | Show the ip address assigned to an interface |
| systemctl status bird | Show the status of the BIRD service |
| bird -p -c /etc/bird/bird.conf | Check if a file is a valid BIRD config file |
| systemctl restart bird | Restart the BIRD service |
| birdc | Communicate with a running BIRD |
| bird> show ... | Shows general information about multiple protocols/BIRD internals, type "show ?" for a list of information sources |
| bird> show ospf | Basic overview of OSPF, type ? for additional options |
| sysctl net.ipv4.ip_forward | Show if linux is forwarding ipv4 routes (1 yes, 0 no) |
| ip route | Show all routes in database |
| ping xxx.xxx.xxx.xxx | Ping an ip address  |
| mtr xxx.xxx.xxx.xxx | Traceroute to an ip address |
| sudo ifconfig INTERFACE down | Shutdown an INTERFACE |
| sudo ifconfig INTERFACE up | Turn an INTERFACE on |
| tcpdump -i INTERFACE | Sniff all traffic on an INTERFACE  |
| tcpdump -i INTERFACE proto ospf | Sniff all ospf packets |
| curl URL:PORT | Transfers data from remote server (writes it to terminal if nothing is added), in this case a website |
| iperf3 -s | Start iperf server |
| iperf3 -c xxx.xxx.xxx.xxx | Start an iperf test to specified server ip |
| tc qdisc add dev ens4 root netem delay 20ms loss 0.1% | Add artificial delay and packet loss to interface |
| sudo tc qdisc del dev ens4 root | Remove settings from above  |
| mitmproxy -s "script.py" | Start mitmproxy, passing an injection script to it. |
|  |  |
|  |  |
|  |  |


