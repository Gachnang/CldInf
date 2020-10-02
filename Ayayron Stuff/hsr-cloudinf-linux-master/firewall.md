# 4. Adding a firewall 
## Port scan
All open ports on the webserver can be found by running nmap on the client. Following nmap command scans the most common tcp ports.
```bash
root@client:~# nmap -sS 192.168.1.100

Starting Nmap 7.60 ( https://nmap.org ) at 2019-11-10 15:58 UTC
Nmap scan report for 192.168.1.100
Host is up (0.00091s latency).
Not shown: 999 closed ports
PORT     STATE SERVICE
8080/tcp open  http-proxy

Nmap done: 1 IP address (1 host up) scanned in 14.49 seconds
```
As you can see port 8080 where the webserver is located can be scanned by nmap.

## Firewall setup
We setup the firewall on R5. TODO Reason

First disable iptables.
```bash
iptables -F
```


```bash

```

```bash

```

```bash

```

```bash

```