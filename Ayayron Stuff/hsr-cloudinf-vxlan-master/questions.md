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

