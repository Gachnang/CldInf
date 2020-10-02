# hsr-cloudinf-vxlan
This file includes the documentation for all exercises.

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

# Questions
## 1
Compare the design with Flood&Flearn and the design with BGP eVPN. What do you think are the advantages and disadvantages of each control-plane approach (technical and non-technical)? Which solution for the control-plane would you recommend if a company would like to deploy VXLAN in their Datacenter? Justify your answer.


The main differentiator between `Flood & Learn` and `BGP eVPN` in a VXLAN environment is how host detection is handled.   
In the `Flood & Learn` approach an ARP request will be sent to all connected Spines (in the VXLAN fabric) and forwarded to all Leafs when a Host is unknown.   
eVPN MP-BGP adds a control plane to the VXLAN. To learn new hosts, unnecessary forwarding of ARP requests over the entire fabric are significantly reduced. The Leafs (VTEPs) form BGP edge nodes and share routes among each other using BGP NLRI advertisements. With this setup when a host connects and sends any packet to the default gateway it's MAC is advertised using BGP, so it's in every VTEPs forwarding table. 


The first approach offers a simple, easy to setup solution while the second approach is more complex since it adds a BGP setup to the network.  
This complexity offers a much more efficient approach to MAC address propagation though.
VXLAN offers an efficient use of resources within the data center since no links are being blocked because of STP.   
eVPN MP-BGP compared to `Flood & Learn` adds even more efficiency to this approach since ARP requests are minimized across the data center fabric.  
While initially more time intensive to deploy it will offer a much more efficient and likely more scalable network. So it will most likely be the best option for companies looking to build a sustainable data center network with efficiency of resource usage in mind.  

## 2
Copy a MP-BGP EVPN Route type 2 update with all the BGP attributes (using the show bgp l2vpn evpn x.x.x.x where x.x.x.x is an IP address) from the CLI into your documentation.

Show EVPN Route type 2 update
```bash
show bgp l2vpn evpn 172.21.141.20

```

BGP routing table information for route type 2:
```bash
BGP routing table information for VRF default, address family L2VPN EVPN
Route Distinguisher: 192.168.0.8:32908    (L2VNI 50141)
BGP routing table entry for [2]:[0]:[0]:[48]:[32a1.b28f.8d4f]:[32]:[172.21.141.2
0]/272, version 92
Paths: (1 available, best #1)
Flags: (0x000212) (high32 00000000) on xmit-list, is in l2rib/evpn, is not in HW

  Advertised path-id 1
  Path type: internal, path is valid, is best path, no labeled nexthop, in rib
             Imported from 192.168.0.9:32908:[2]:[0]:[0]:[48]:[32a1.b28f.8d4f]:[
32]:[172.21.141.20]/272
  AS-Path: NONE, path sourced internal to AS
    192.168.0.19 (metric 81) from 192.168.0.6 (192.168.0.6)
      Origin IGP, MED not set, localpref 100, weight 0
      Received label 50141 50999
      Extcommunity: RT:65000:50141 RT:65000:50999 ENCAP:8 Router MAC:0c4e.b739.9
e07
      Originator: 192.168.0.9 Cluster list: 192.168.0.6

  Path-id 1 not advertised to any peer

Route Distinguisher: 192.168.0.9:32908
BGP routing table entry for [2]:[0]:[0]:[48]:[32a1.b28f.8d4f]:[32]:[172.21.141.2
0]/272, version 91
Paths: (2 available, best #2)
Flags: (0x000202) (high32 00000000) on xmit-list, is not in l2rib/evpn, is not i
n HW

  Path type: internal, path is valid, not best reason: Neighbor Address, no labe
led nexthop
  AS-Path: NONE, path sourced internal to AS
    192.168.0.19 (metric 81) from 192.168.0.7 (192.168.0.7)
      Origin IGP, MED not set, localpref 100, weight 0
      Received label 50141 50999
      Extcommunity: RT:65000:50141 RT:65000:50999 ENCAP:8 Router MAC:0c4e.b739.9
e07
      Originator: 192.168.0.9 Cluster list: 192.168.0.7

  Advertised path-id 1
  Path type: internal, path is valid, is best path, no labeled nexthop
             Imported to 2 destination(s)
  AS-Path: NONE, path sourced internal to AS
    192.168.0.19 (metric 81) from 192.168.0.6 (192.168.0.6)
      Origin IGP, MED not set, localpref 100, weight 0
      Received label 50141 50999
      Extcommunity: RT:65000:50141 RT:65000:50999 ENCAP:8 Router MAC:0c4e.b739.9
e07
      Originator: 192.168.0.9 Cluster list: 192.168.0.6

  Path-id 1 not advertised to any peer
```

## 3
Modify your configuration in your lab in order to display a MP-BGP EVPN Route type 3 update. Copy a MP-BGP EVPN Route type 3 update with all the BGP attributes (using the show bgp l2vpn evpn x.x.x.x where x.x.x.x is an IP address) from the CLI into your documentation.

First we change the current config.  
We enable Ingress replication via BGP and disable multicast.  
This enables sending and receiving BUM traffic for the VNIs. 
The following commands were done on all leafes:

```bash
interface nve1
  member vni 50140
    no mcast-group 239.0.0.1
    ingress-replication protocol bgp
  member vni 50141
    no mcast-group 239.0.0.1
    ingress-replication protocol bgp
```

Then we detect route type 3 updates trough the following command:
```bash
show bgp l2vpn evpn route-type 3
```

And show EVPN Route type 3 update
```bash
show bgp l2vpn evpn 192.168.0.18
```

BGP routing table information for route type 3:
```bash
BGP routing table information for VRF default, address family L2VPN EVPN
Route Distinguisher: 192.168.0.8:32907    (L2VNI 50140)
BGP routing table entry for [3]:[0]:[32]:[192.168.0.18]/88, version 102
Paths: (1 available, best #1)
Flags: (0x000002) (high32 00000000) on xmit-list, is not in l2rib/evpn

  Advertised path-id 1
  Path type: local, path is valid, is best path, no labeled nexthop
  AS-Path: NONE, path locally originated
    192.168.0.18 (metric 0) from 0.0.0.0 (192.168.0.8)
      Origin IGP, MED not set, localpref 100, weight 32768
      Extcommunity: RT:65000:50140 ENCAP:8
      PMSI Tunnel Attribute:
        flags: 0x00, Tunnel type: Ingress Replication
        Label: 50140, Tunnel Id: 192.168.0.18

  Path-id 1 advertised to peers:
    192.168.0.6        192.168.0.7
```

## 4
Modify your configuration in your lab in order to see a MP-BGP EVPN Route type 5 update. Copy a MP-BGP EVPN Route type 5 update with all the BGP attributes (using the show bgp l2vpn evpn x.x.x.x where x.x.x.x is an IP address) from the CLI into your documentation.

Again we first change the configuration.
We add the relevant subnet for routing on the leaves: Leaf 1 and leaf 3 get the 172.21.140.1/24 subnet and Leaf 2 and 4 get the 172.21.141.1/24 subnet.
```bash
# Leaf 1
router bgp 65000
  vrf Tenant-1
    address-family ipv4 unicast
      network 172.21.140.1/24
      advertise l2vpn evpn

# Leaf 2
router bgp 65000
  vrf Tenant-1
    address-family ipv4 unicast
      network 172.21.141.1/24
      advertise l2vpn evpn

# Leaf 3
router bgp 65000
  vrf Tenant-1
    address-family ipv4 unicast
      network 172.21.140.1/24
      advertise l2vpn evpn

# Leaf 4
router bgp 65000
  vrf Tenant-1
    address-family ipv4 unicast
      network 172.21.141.1/24
      advertise l2vpn evpn
```

Now we use the following command to detect route type 5 updates:
```bash
show bgp l2vpn evpn route-type 5
```

And use the following command to get a specific route update:
```bash
show bgp l2vpn evpn 172.21.141.0
```

BGP routing table information for route type 5 updates:
```bash
BGP routing table information for VRF default, address family L2VPN EVPN
Route Distinguisher: 192.168.0.9:3
BGP routing table entry for [5]:[0]:[0]:[24]:[172.21.141.0]/224, version 162
Paths: (2 available, best #2)
Flags: (0x000002) (high32 00000000) on xmit-list, is not in l2rib/evpn, is not i
n HW

  Path type: internal, path is valid, not best reason: Neighbor Address, no labe
led nexthop
  Gateway IP: 0.0.0.0
  AS-Path: NONE, path sourced internal to AS
    192.168.0.19 (metric 81) from 192.168.0.7 (192.168.0.7)
      Origin IGP, MED not set, localpref 100, weight 0
      Received label 50999
      Extcommunity: RT:65000:50999 ENCAP:8 Router MAC:0c4e.b739.9e07
      Originator: 192.168.0.9 Cluster list: 192.168.0.7

  Advertised path-id 1
  Path type: internal, path is valid, is best path, no labeled nexthop
             Imported to 1 destination(s)
  Gateway IP: 0.0.0.0
  AS-Path: NONE, path sourced internal to AS
    192.168.0.19 (metric 81) from 192.168.0.6 (192.168.0.6)
      Origin IGP, MED not set, localpref 100, weight 0
      Received label 50999
      Extcommunity: RT:65000:50999 ENCAP:8 Router MAC:0c4e.b739.9e07
      Originator: 192.168.0.9 Cluster list: 192.168.0.6

  Path-id 1 not advertised to any peer

Route Distinguisher: 192.168.0.11:3
BGP routing table entry for [5]:[0]:[0]:[24]:[172.21.141.0]/224, version 170
Paths: (2 available, best #2)
Flags: (0x000002) (high32 00000000) on xmit-list, is not in l2rib/evpn, is not i
n HW

  Path type: internal, path is valid, not best reason: Neighbor Address, no labe
led nexthop
  Gateway IP: 0.0.0.0
  AS-Path: NONE, path sourced internal to AS
    192.168.0.111 (metric 81) from 192.168.0.7 (192.168.0.7)
      Origin IGP, MED not set, localpref 100, weight 0
      Received label 50999
      Extcommunity: RT:65000:50999 ENCAP:8 Router MAC:0c4e.b7bc.5e07
      Originator: 192.168.0.11 Cluster list: 192.168.0.7

  Advertised path-id 1
  Path type: internal, path is valid, is best path, no labeled nexthop
             Imported to 1 destination(s)
  Gateway IP: 0.0.0.0
  AS-Path: NONE, path sourced internal to AS
    192.168.0.111 (metric 81) from 192.168.0.6 (192.168.0.6)
      Origin IGP, MED not set, localpref 100, weight 0
      Received label 50999
      Extcommunity: RT:65000:50999 ENCAP:8 Router MAC:0c4e.b7bc.5e07
      Originator: 192.168.0.11 Cluster list: 192.168.0.6

  Path-id 1 not advertised to any peer
```

