# 2.2.1 OSPF Configuration
This file shows all steps to configure a Linux OSPF network with 2 clients. The topology can be found in topology.png.

The full configuration for every step and every device can be found in "full-config".
Username: ins

Password: a-a-ron

On webserver: ins@lab
## General settings
Connect to all routers and clients, change the password to "a-a-ron", change the hostname and replace HOSTNAME with the corresponding hostname:
```bash
passwd ins
# Enter a-a-ron
vim /etc/cloud/cloud.cfg
# Add or uncomment "preserve_hostname: true"
hostnamectl set-hostname HOSTNAME
vim /etc/hosts
# Add 127.0.0.1 client
```
This configuration requires a reboot to be applied:
```bash
reboot
```
## Interface configuration
Now let's configure the interfaces on all devices, e.g. R1 looks like this:
```bash
cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [172.16.0.1/24]
        ens3:
            addresses: [10.0.1.1/24]
EOF
```
The client requires a default route to R1 so it's cloud init file looks like this:
```bash
cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [172.16.0.100/24]
            gateway4: 172.16.0.1
EOF
```
Apply and check the settings:
```bash
netplan apply
ip addr show ens2
```

## BIRD Configuration
Now OSPF is configured on all routers using BIRD.
Check if bird is running:
```bash
systemctl status bird
```
All settings for BIRD are written in /etc/bird/bird.conf:
```bash
cat << EOF > /etc/bird/bird.conf
router id 1.1.1.1;

protocol ospf  BirdyOSPF {
    import all;
    export all;

    tick 2;
    area 0 {
        interface "ens3" {
            type broadcast;
        };
        interface "ens2" {
            type broadcast;
            stub yes;
        };
        networks{
            10.0.1.0/24;
        };
    };
}

protocol device { }
protocol kernel {
    metric 64;
    import all;
    export all;
    learn;
    persist;
}
EOF
```
OSPFv2 is the default value, so it must not be explicitly configured.

Since there is only one OSPF process running on each device so no instance id is needed.

tick 2; makes the router wait 2 second when a link update arrives, this way multiple updates are processed together (default is 1). If the CPU is still overloaded this value can be set to a higher value, but it will make route propagation slower.

To make routes be kept on restart nothing has to be added, since graceful restart is enabled in aware mode by default.

Even though they should be detected automatically as such all stub interfaces are declared explicitly, clients connected to a stub interface will not receive any OSPF messages.

Cost is not defined statically so it can change when a link for whatever reason changes speed. Hello packages are sent in a 10 second interval by default which is a reasonable value.

All networks participating in OSPF should be defined in networks {...}. Routers with multiple OSPF links will have multiple entries as opposed to R1 here.


Now check if the file is syntactically correct and restart the BIRD service to apply settings:
```bash
bird -p -c /etc/bird/bird.conf
systemctl restart bird
```

# 2.2.2 Enable IP forwarding on all routers:
The last thinf to configure to make the whole network work properly is enabling IP forwarding on all routers:

cUncomment #net.ipv4.ip_forward=1 in sysctl.conf:
```bash
vim  /etc/sysctl.conf
```
Restart procps to load conf and verify that forwarding is enabled:
```bash
sudo /etc/init.d/procps restart
sysctl net.ipv4.ip_forward
```

# Verification
## 2.2.3 Verification:
# Route failover
First verify that the setup properly works by pinging and running a traceroute to the server from the client:
```bash
ping 192.168.1.100
mtr 192.168.1.100
```
As it is the shortest, the route should be following: 172.16.0.1 => 10.0.1.2 => 10.0.2.2 => 10.0.3.1 => 192.168.1.100

To test if route failover works we now connect to r2 and turn off the interface "ens4" as root:
```bash
sudo ifconfig ens4 down
```
Now run the traceroute again (it might take a couple of seconds to update all routes):
```bash
mtr 192.168.1.100
```
The route over R4 should now be used as it now is the shortest route: 172.16.0.1 => 10.0.1.2 => 10.0.4.2 => 10.0.5.1 => 10.0.3.1 => 192.168.1.100

"ens4" can be enabled again on R2:
```bash
sudo ifconfig ens4 up
```

# Passive interfaces
To check if the clients don't recieve any OSPF packages, client facing interfaces on the routers can be sniffed. Since the clients are only connected to the borders we don't need to sniff on them directly to be sure that they don't receive any OSPF packages. The steps are documented for the client side, the same can be done for the server on R5. Watch out for the swapped interfaces on R5 (ens2 is OSPF facing and ens3 client)!.

On R1 Sniff for ospf packages on ens3. Hello timers have been kept to their default values, so every 10 second you should se a out and ingoing OSPFv2 pakage:
```bash
tcpdump -i ens3 proto ospf
```
Do the same for ens2, no packages should be recorded. To verify that packages are captured "proto ospf" can be removed from the command, then ping the server from the client. You should be able to see the pings and other packages now.
```bash
tcpdump -i ens2 proto ospf
```

# Access Website
To access the website just run following curl command, since we're runnign this on the console unrendered HTML plain text should be returned, giving some information about the web server:
```bash
curl 192.168.1.100:8080
```

