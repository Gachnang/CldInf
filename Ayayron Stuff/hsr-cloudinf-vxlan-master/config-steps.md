# hsr-cloudinf-vxlan

## Setup information
**GNS3 server:** 10.21.0.15  
**Project:** CloudInf_VXLAN_STUDENT-3  
**Credentials for Devices:** admin/admin  

## Configuration with Flood & Learn
Precheck
```bash
# Check OSPF configuration on Spine-1
You can check the ospf conifguration by displaying all ospf neighbors and pinging the interfaces. 
show ip route ospf
ping 10.0.128.2

# Check OSPF configuration on Spine-2
show ip route ospf
ping 10.0.128.1
```

Configure Multicast
```bash
# Spine-1
feature pim

interface loopback1
ip pim sparse-mode
ip pim RP-address 192.168.0.100

interface ethernet1/1-4
ip pim sparse-mode

# Spine-2
feature pim

interface loopback1
ip pim sparse-mode
ip pim RP-address 192.168.0.100

interface ethernet1/1-4
ip pim sparse-mode

# Leaf1-4
feature pim
interface Ethernet1/1-2
ip pim sparse-mode
ip pim RP-address 192.168.0.100
interface loopback1
ip pim sparse-mode

# Check multicast
show ip mroute
show ip pim neighbor
show nve peers
```

Configure VLANs and link to VNIs
```bash
# Define VLAN and map to VNI
feature vn-segment-vlan-based
vlan 140
vn-segment 50140
```

Create the VXLAN tunnel interfaces and add the tunnel endpoints to the VNI and multicast group
```bash
# Create VXLAN on all leafes
feature nv overlay
interface nve1
  source-interface loopback1
  member vni 50140 mcast-group 239.0.0.140
  no shutdown

# Check
show nve peers detail
show nve vni 50140
```

## Configuration with eVPN
Configure Anycast Multicast: The basic multicast configuration can be taken from the previous topology.  
```bash
# Spine-1
feature pim
feature vn-segment-vlan-based

interface lo0
  ip router ospf 1 area 0.0.0.0

interface loopback1
ip pim sparse-mode
ip pim RP-address 192.168.0.100

interface ethernet1/1-4
ip pim sparse-mode

# Spine-2
feature pim
feature vn-segment-vlan-based

interface lo0
  ip router ospf 1 area 0.0.0.0

interface loopback1
ip pim sparse-mode
ip pim RP-address 192.168.0.100

interface ethernet1/1-4
ip pim sparse-mode

# Leaf1-4
feature pim
interface Ethernet1/1-2
ip pim sparse-mode
ip pim RP-address 192.168.0.100
interface loopback1
ip pim sparse-mode
```

On the Spines add the configuration for anycast  
```bash
# Spine-1
ip pim anycast-rp 192.168.0.100 192.168.0.6
ip pim anycast-rp 192.168.0.100 192.168.0.7

# Spine-2
ip pim anycast-rp 192.168.0.100 192.168.0.6
ip pim anycast-rp 192.168.0.100 192.168.0.7
```

On the Leafes configure the anycast gateway MAC address  
```bash
# Leaf-1-4
nv overlay evpn
fabric forwarding anycast-gateway-mac 0000.2222.3333
```

Configure basic iBGP reachability
```bash
# Spine-1
feature bgp
feature nv overlay
nv overlay evpn
feature vn-segment-vlan-based

int lo0
    ip router ospf 1 area 0.0.0.0

router bgp 65000
router-id 192.168.0.6
  address-family ipv4 unicast
  address-family l2vpn evpn
  retain route-target all

  neighbor 192.168.0.8 remote-as 65000
      update-source loopback0
      address-family l2vpn evpn
        send-community
        send-community extended
        route-reflector-client
      address-family ipv4 unicast
        send-community
        send-community extended
        route-reflector-client

  neighbor 192.168.0.9 remote-as 65000
      update-source loopback0
      address-family l2vpn evpn
        send-community
        send-community extended
        route-reflector-client
      address-family ipv4 unicast
        send-community
        send-community extended
        route-reflector-client

  neighbor 192.168.0.10 remote-as 65000
      update-source loopback0
      address-family l2vpn evpn
        send-community
        send-community extended
        route-reflector-client
      address-family ipv4 unicast
        send-community
        send-community extended
        route-reflector-client

  neighbor 192.168.0.11 remote-as 65000
      update-source loopback0
      address-family l2vpn evpn
        send-community
        send-community extended
        route-reflector-client
      address-family ipv4 unicast
        send-community
        send-community extended
        route-reflector-client

# Spine-2
feature bgp
feature nv overlay
nv overlay evpn
feature vn-segment-vlan-based

int lo0
  ip router ospf 1 area 0.0.0.0

router bgp 65000
router-id 192.168.0.7
    address-family ipv4 unicast
    address-family l2vpn evpn
    retain route-target all

    neighbor 192.168.0.8 remote-as 65000
        update-source loopback0
        address-family l2vpn evpn
          send-community
          send-community extended
          route-reflector-client
        address-family ipv4 unicast
          send-community
          send-community extended
          route-reflector-client

    neighbor 192.168.0.9 remote-as 65000
        update-source loopback0
        address-family l2vpn evpn
          send-community
          send-community extended
          route-reflector-client
        address-family ipv4 unicast
          send-community
          send-community extended
          route-reflector-client

    neighbor 192.168.0.10 remote-as 65000
        update-source loopback0
        address-family l2vpn evpn
          send-community
          send-community extended
          route-reflector-client
        address-family ipv4 unicast
          send-community
          send-community extended
          route-reflector-client

    neighbor 192.168.0.11 remote-as 65000
        update-source loopback0
        address-family l2vpn evpn
          send-community
          send-community extended
          route-reflector-client
        address-family ipv4 unicast
          send-community
          send-community extended
          route-reflector-client

# Leaf 1
feature bgp
interface loopback0
ip address 192.168.0.8/32
ip router ospf 1 area 0.0.0.0
ip pim sparse-mode

# Leaf 2
feature bgp
interface loopback0
ip address 192.168.0.9/32
ip router ospf 1 area 0.0.0.0
ip pim sparse-mode

# Leaf 3 
feature bgp
interface loopback0
ip address 192.168.0.10/32
ip router ospf 1 area 0.0.0.0
ip pim sparse-mode

# Leaf 4
feature bgp
interface loopback0
ip address 192.168.0.11/32
ip router ospf 1 area 0.0.0.0
ip pim sparse-mode
```

Configure VLANs: Configure the VLANs 140, 141 and 999. Dont forget to assign the VNIs 50140, 50141 or 50999 to the VLANs.
```bash
# Leaf 1-4
feature vn-segment-vlan-based
vlan 140
vn-segment 50140
vlan 141
vn-segment 50141
vlan 999
vn-segment 50999
```

Configure a VRF called Tenant-1 on the Leaf switches
```bash
vrf context Tenant-1
  vni 50999
  rd auto
  address-family ipv4 unicast
    route-target both auto
    route-target both auto evpn
```

Configure the SVIs
```bash
# Leaf 1-4
interface Vlan 140
  no shutdown
  vrf member Tenant-1
  ip address 172.21.140.1/24
  fabric forwarding mode anycast-gateway
  no ip redirects

interface Vlan 141
  no shutdown
  vrf member Tenant-1
  ip address 172.21.141.1/24
  fabric forwarding mode anycast-gateway
  no ip redirects

interface Vlan 999
  no shutdown
  vrf member Tenant-1
  ip forward
```

Configure/adjust the NVE interface
```bash
# Leaf 1-4
feature nv overlay
interface nve1
  no shutdown
  source-interface loopback1
  host-reachability protocol bgp
  member vni 50999 associate-vrf
  member vni 50140
    mcast-group 239.0.0.1
  member vni 50141
    mcast-group 239.0.0.2
```

Configure EBGP EVPN control plane
```bash

# Leaf-1
router bgp 65000
router-id 192.168.0.8
  address-family ipv4 unicast
  address-family l2vpn evpn
  retain route-target all

  neighbor 192.168.0.6 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast
      send-community
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  neighbor 192.168.0.7 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast 
      send-community  
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  vrf Tenant-1


# Leaf-2
router bgp 65000
router-id 192.168.0.9
  address-family ipv4 unicast
  address-family l2vpn evpn
  retain route-target all
  neighbor 192.168.0.6 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast
      send-community
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  neighbor 192.168.0.7 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast 
      send-community  
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  vrf Tenant-1
  
# Leaf-3
router bgp 65000
router-id 192.168.0.10
  address-family ipv4 unicast
  address-family l2vpn evpn
  retain route-target all
  neighbor 192.168.0.6 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast
      send-community
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  neighbor 192.168.0.7 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast 
      send-community  
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  vrf Tenant-1

# Leaf-4
router bgp 65000
router-id 192.168.0.11
  address-family ipv4 unicast
  address-family l2vpn evpn
  retain route-target all
  neighbor 192.168.0.6 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast
      send-community
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  neighbor 192.168.0.7 remote-as 65000
    update-source loopback0
    address-family ipv4 unicast 
      send-community  
      send-community extended
    address-family l2vpn evpn
      send-community 
      send-community extended 
  vrf Tenant-1
```

Change vlan interface 
```bash
# Leaf-2
interface Ethernet1/9
no switchport access vlan 140
switchport access vlan 141

# Leaf-4
interface Ethernet1/9
no switchport access vlan 140
switchport access vlan 141
```

Save config for all devices
```bash
# Spine 1-2, Leaf1-4
copy running-config startup-config
```

Debug on Servers
```bash
# Debugging Server 1
route add -net 172.21.0.0/16 gw 172.21.140.1 dev eth0
ping 172.21.141.20 -c 1
ping 172.21.140.30 -c 1
ping 172.21.141.40 -c 1

# Debugging Server 2
route add -net 172.21.0.0/16 gw 172.21.141.1 dev eth0
ping 172.21.140.10 -c 1
ping 172.21.140.30 -c 1
ping 172.21.141.40 -c 1

# Debugging Server 3
route add -net 172.21.0.0/16 gw 172.21.140.1 dev eth0
ping 172.21.140.10 -c 1
ping 172.21.141.20 -c 1
ping 172.21.141.40 -c 1

# Debugging Server 4
route add -net 172.21.0.0/16 gw 172.21.141.1 dev eth0
ping 172.21.140.10 -c 1
ping 172.21.141.20 -c 1
ping 172.21.140.30 -c 1
```

Debug on Switches
```bash
show ip bgp summary
show bgp ipv4 unicast summary
show bgp l2vpn evpn summary
show l2route evpn mac-ip all
```