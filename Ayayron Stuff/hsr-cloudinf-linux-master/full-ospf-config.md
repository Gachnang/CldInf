# hsr-cloudinf-linux

### Password
```bash
passwd ins


```

### Client
```bash
sudo -s

vim /etc/cloud/cloud.cfg
# preserve_hostname: true
hostnamectl set-hostname client
vim /etc/hosts
# 127.0.0.1 client
reboot

# Setup network
cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [172.16.0.100/24]
            gateway4: 172.16.0.1
EOF
netplan apply
ip addr show ens2
```

### MITM
```bash
sudo -s

vim /etc/cloud/cloud.cfg
# preserve_hostname: true
hostnamectl set-hostname mitm
vim /etc/hosts
# 127.0.0.1 mitm
reboot

cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [10.0.6.1/24]
EOF
netplan apply
ip addr show ens2

systemctl status bird
systemctl restart bird

cat << EOF > /etc/bird/bird.conf
router id 6.6.6.6;

protocol ospf  BirdyOSPF {
    import all;
    export all;

    tick 2;
    area 0 {
        interface "ens2" {
            type broadcast;
        };
        networks{
            10.0.6.0/24;
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
bird -p -c /etc/bird/bird.conf
systemctl restart bird
```

### R1
```bash
sudo -s

vim /etc/cloud/cloud.cfg
# preserve_hostname: true
hostnamectl set-hostname r1
vim /etc/hosts
# 127.0.0.1 r1
reboot

cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [172.16.0.1/24]
        ens3:
            addresses: [10.0.1.1/24]
EOF
netplan apply
ip addr show

systemctl status bird
systemctl restart bird

cat << EOF > /etc/bird/bird.conf
# As a reference see: http://bird.network.cz/

# Router ID as per requirements
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
# Check if your bird file is valid (no message if it's correct):
bird -p -c /etc/bird/bird.conf
# Restart the bird service to apply changes
systemctl restart bird
```

### R2
```bash
sudo -s

vim /etc/cloud/cloud.cfg
# preserve_hostname: true
hostnamectl set-hostname r2
vim /etc/hosts
# 127.0.0.1 r2
reboot

cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [10.0.1.2/24]
        ens3:
            addresses: [10.0.4.1/24]
        ens4:
            addresses: [10.0.2.1/24]
EOF
netplan apply
ip addr show

systemctl status bird
systemctl restart bird

cat << EOF > /etc/bird/bird.conf
router id 2.2.2.2;
protocol ospf  BirdyOSPF {
    import all;
    export all;
    tick 2;
    area 0 {
        interface "ens2", "ens3", "ens4" {
            type broadcast;
        };
        networks{
            10.0.1.0/24;
            10.0.2.0/24;
            10.0.4.0/24;
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
bird -p -c /etc/bird/bird.conf
systemctl restart bird
```

### R3
```bash
sudo -s

vim /etc/cloud/cloud.cfg
# preserve_hostname: true
hostnamectl set-hostname r3
vim /etc/hosts
# 127.0.0.1 r3
reboot

cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [10.0.2.2/24]
        ens3:
            addresses: [10.0.5.1/24]
        ens4:
            addresses: [10.0.3.2/24]
EOF
netplan apply
ip addr show

systemctl status bird
systemctl restart bird

cat << EOF > /etc/bird/bird.conf
router id 3.3.3.3;

protocol ospf  BirdyOSPF {
    import all;
    export all;
    tick 2;
    area 0 {
        interface "ens2", "ens3", "ens4" {
            type broadcast;
        };
        networks {
            10.0.2.0/24;
            10.0.3.0/24;
            10.0.5.0/24;
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
bird -p -c /etc/bird/bird.conf
systemctl restart bird
```

### R4
```bash
sudo -s
vim /etc/cloud/cloud.cfg
# preserve_hostname: true
hostnamectl set-hostname r4
vim /etc/hosts
# 127.0.0.1 r4
reboot

cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [10.0.4.2/24]
        ens3:
            addresses: [10.0.5.2/24]
        ens4:
            addresses: [10.0.6.2/24]
EOF
netplan apply
ip addr show

systemctl status bird
systemctl restart bird

cat << EOF > /etc/bird/bird.conf
router id 4.4.4.4;

protocol ospf  BirdyOSPF {
    import all;
    export all;
    tick 2;
    area 0 {
        interface "ens2", "ens3", "ens4" {
            type broadcast;
        };
        networks {
            10.0.4.0/24;
            10.0.5.0/24;
            10.0.6.0/24;
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
bird -p -c /etc/bird/bird.conf
systemctl restart bird
```

### R5
```bash
sudo -s
vim /etc/cloud/cloud.cfg
# preserve_hostname: true
hostnamectl set-hostname r5
vim /etc/hosts
# 127.0.0.1 r5
reboot

cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens2:
            addresses: [10.0.3.1/24]
        ens3:
            addresses: [192.168.1.1/24]
EOF
netplan apply
ip addr show

systemctl status bird
systemctl restart bird

cat << EOF > /etc/bird/bird.conf
router id 5.5.5.5;

protocol ospf  BirdyOSPF {
    import all;
    export all;
    tick 2;
    area 0 {
        stub no;
        interface "ens2" {
            type broadcast;
        };
        interface "ens3" {
            type broadcast;
            stub yes;
        };
        networks {
            10.0.3.0/24;
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
bird -p -c /etc/bird/bird.conf
systemctl restart bird
```

### Webserver
```bash
# Check default gateway
ip route

```