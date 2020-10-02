# cloudinf-docker
All kvm files (Cloud-Init and bridge xmls) are under kvm/.   
Dockerfiles (web/api) are in their respective folders.   
Docker-Compose files can be found in the projects root.   
The following README includes the KVM and Docker documentation.   

# KVM documentation
```bash
# Connect to host and become root
ssh ins@group3.playground.ins.hsr.ch
sudo -s 


# Install dependencies
apt install -y qemu-kvm libvirt-bin virtinst bridge-utils

# Check install
kvm-ok

# Reboot
reboot

# Check
brctl show

# Define networks
cat > hostonlynetwork.xml <EOF
<network>
  <name>hostonlynetwork</name>
  <bridge name='hostonlynetwork' stp='on' delay='0'/>
  <ip address='10.2.0.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat > natnetwork.xml <EOF
<network>
  <name>natnetwork</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='natnetwork' stp='on' delay='0'/>
  <ip address='10.1.0.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

# Add networks from xml
virsh net-define hostonlynetwork.xml
virsh net-define natnetwork.xml

# Download ubuntu images
cd /home/ins/vms
wget -O bionic-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img

# Resize images
qemu-img resize bionic-server-cloudimg-amd64.img 10G

# VM1 disk
qemu-img create -f qcow2 -F qcow2 -b bionic-server-cloudimg-amd64.img vm1.qcow2

# VM2 disk
qemu-img create -f qcow2 -F qcow2 -b bionic-server-cloudimg-amd64.img vm2.qcow2

# VM1 Config
cd ../
mkdir cloudinit-vm1

cat > cloudinit-vm1/meta-data <<EOF
dsmode: local
EOF

cat > cloudinit-vm1/user-data <<EOF
#cloud-config
user: sysadmin
password: cisco
chpasswd: { expire: False }
ssh_pwauth: True
hostname: ubuntu
EOF

cat > cloudinit-vm1/network-config <<EOF
---
version: 2
ethernets:
  ens2:
    addresses:
      - 10.1.0.10/24
    gateway4: 10.1.0.1
    nameservers:
      addresses:
        - 152.96.120.53
        - 152.96.120.54
  ens3:
    addresses:
      - 10.2.0.10/24
EOF

# Generate ISO
genisoimage -output ubuntudata-vm1.iso -volid cidata -joliet \
        -rock cloudinit-vm1/user-data cloudinit-vm1/meta-data \
        cloudinit-vm1/network-config

# Create VM1
virt-install --name ubuntu --memory 2048 --vcpus 2 --disk /home/ins/vms/vm1.qcow2,device=disk --disk /home/ins/ubuntudata-vm1.iso,device=cdrom --graphics none --import --noautoconsole --network bridge=natnetwork --network bridge=hostonlynetwork --os-variant ubuntu18.04 

# Connect to console to observe deployment
virsh console ubuntu

# Exit console
CTRL+Shift+5
CTRL+Shift+]

# VM2 Config
mkdir cloudinit-vm2

cat > cloudinit-vm2/meta-data <<EOF
dsmode: local
EOF

cat > cloudinit-vm2/user-data <<EOF
#cloud-config
user: sysadmin
password: cisco
chpasswd: { expire: False }
ssh_pwauth: True
hostname: "ubuntu-postgres"
EOF

cat > cloudinit-vm2/network-config <<EOF
---
version: 2
ethernets:
  ens2:
    addresses:
      - 10.2.0.20/24
  ens3:
    dhcp4: True
    nameservers:
      addresses:
        - 152.96.120.53
        - 152.96.120.54
EOF

# Generate ISO
genisoimage -output ubuntudata-vm2.iso -volid cidata -joliet \
        -rock cloudinit-vm2/user-data cloudinit-vm2/meta-data \
        cloudinit-vm2/network-config

# Create VM2
virt-install --name ubuntu-postgres --memory 2048 --vcpus 2 --disk /home/ins/vms/vm2.qcow2,device=disk --disk /home/ins/ubuntudata-vm2.iso,device=cdrom --graphics none --import --noautoconsole --network bridge=hostonlynetwork --network bridge=virbr0 --os-variant ubuntu18.04 

# Connect to console to observe deployment
virsh console ubuntu-postgres

# Exit console
CTRL+Shift+5
CTRL+Shift+]

# Port forwarding
iptables -I FORWARD -o natnetwork -d 10.1.0.10 -j ACCEPT
iptables -t nat -I PREROUTING -p tcp -i ens160 --dport 443 -j DNAT --to 10.1.0.10:8443
iptables -t nat -I PREROUTING -p tcp -i ens160 --dport 80 -j DNAT --to 10.1.0.10:8080
iptables -t nat -A POSTROUTING -s 10.1.0.0/24 -j MASQUERADE
iptables -A FORWARD -o natnetwork -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i natnetwork -o ens160 -j ACCEPT

# Install docker on the VMs and setup network
ssh sysadmin@10.2.0.10
apt-get update; apt-get install docker unzip
adduser sysadmin docker

wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Linux-x86_64
chmod +x /usr/local/bin/docker-compose

ssh sysadmin@10.2.0.20
apt-get update; apt-get install docker unzip
adduser sysadmin docker

wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Linux-x86_64
chmod +x /usr/local/bin/docker-compose

# Enable libvrtd start on boot
systemctl enable libvirtd

# Enable autostart of VMs
virsh autostart ubuntu
virsh autostart ubuntu-postgres

# Save final setup from host files
mkdir kvm/
scp -r "ins@group3.playground.ins.hsr.ch:/home/ins/{cloudinit-vm*,*.xml}" kvm/

# Remove default interface from VM1 (Note: This was done at the end of the KVM _and_ docker setup):
ssh sysadmin@10.2.0.20
sudo shutdown now -h
virsh list --all
virsh domiflist ubuntu-postgres
virsh detach-interface --domain ubuntu-postgres --type bridge --mac 52:54:00:09:03:95 --config
virsh start ubuntu-postgres
```

## Troubleshooting
The following documents occured problems during our KVM deployment and steps we've done to resolve them.

### Different interface naming
Problem: Interfaces were named ens3, ens4 instead of ens2, ens3
This can be seen under:
```bash
cat /proc/net/dev 
```
Solution: Redeploy with different interface order (e.g. ens3, ens4) or reapply with netplan:
```
vim /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
# Change interfaces ens2, ens3

# Reapply
netplan apply
```

### Redeploy
```bash
virsh destroy ubuntu-postgres
virsh undefine ubuntu-postgres
```

### Unhandled non-multipart
Problem: Cloud Init script cancelled because of encoding errors. See message below:
```bash
_init__.py[WARNING]: Unhandled non-multipart (text/x-not-multipart) userdata: 'b'user: sysadmin'...'
```

Solution:
This is caused by #cloud-config being missing from the first line of parts with type text/cloud-config .

# Docker documentation

## Ressources
A note about ressources splitting:

Each VM has 2 cores and 2GB RAM.  
* VM1 splits ressources between 3 Containers and the host system, so each gets 50% of 1 vCPU and 512MB RAM.
* VM2 splits ressources only between 1 Container and the host system, so each gets 1 vCPU and 1GB RAM.


## Deployment
Deployment is done trough ssh/scp because the second vm has no Internet access.
```bash
# Compress code into zip file and copy to host
zip code.zip -r .
scp  code.zip ins@group3.playground.ins.hsr.ch:/home/ins/code.zip

# Copy code to VMs
ssh ins@group3.playground.ins.hsr.ch
scp /home/ins/code.zip sysadmin@10.2.0.10:/home/sysadmin/code.zip
scp /home/ins/code.zip sysadmin@10.2.0.20:/home/sysadmin/code.zip

# VM1
# Note: We use a custom directory to get a clean docker-compose project name
#       Also we use compatiblity to convert compose v3 to v2 limits (CPU, Memory) 
ssh sysadmin@10.2.0.10
unzip /home/sysadmin/code.zip -d /home/sysadmin/cloudinf
cd /home/sysadmin/cloudinf
docker-compose --compatibility  up -d

# Check logs and listened ports
docker-compose logs
ss -tulpn | grep -i 8080
ss -tulpn | grep -i 8443

#VM2
ssh sysadmin@10.2.0.20
unzip /home/sysadmin/code.zip -d /home/sysadmin/cloudinf
cd /home/sysadmin/cloudinf
docker-compose -f docker-compose.backend.yml --compatibility up -d

# Check logs and listened ports
docker-compose logs
ss -tulpn | grep -i 5432
```

# External resources
- https://wiki.libvirt.org/page/VM_lifecycle
- https://cloudinit.readthedocs.io/
- https://jonnev.se/traefik-with-docker-and-lets-encrypt/
- https://docs.docker.com/compose/compose-file/