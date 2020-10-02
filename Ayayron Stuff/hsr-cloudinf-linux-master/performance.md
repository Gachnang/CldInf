# 3. Performance
Now we'll do some performance testing using iperf. Start a session to R2, R3 and R5.

R5 will be used as server, running the server is simply achieved with following command:
```bash
iperf3 -s
```

Now we can test the bandwith from R2 to R5 with iperf3 and latency using ping:
```bash
root@r2:~# iperf3 -c 10.0.3.1
Connecting to host 10.0.3.1, port 5201
[  4] local 10.0.2.1 port 60034 connected to 10.0.3.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  2.70 GBytes  23.2 Gbits/sec    0   3.14 MBytes
[  4]   1.00-2.00   sec  1.83 GBytes  15.7 Gbits/sec    0   3.14 MBytes
[  4]   2.00-3.00   sec  2.54 GBytes  21.8 Gbits/sec    0   3.14 MBytes
[  4]   3.00-4.00   sec  1.93 GBytes  16.6 Gbits/sec    0   3.14 MBytes
[  4]   4.00-5.00   sec  2.30 GBytes  19.8 Gbits/sec    0   3.14 MBytes
[  4]   5.00-6.00   sec  2.06 GBytes  17.7 Gbits/sec    0   3.14 MBytes
[  4]   6.00-7.00   sec  1.90 GBytes  16.3 Gbits/sec    0   3.14 MBytes
[  4]   7.00-8.00   sec  2.24 GBytes  19.3 Gbits/sec    0   3.14 MBytes
[  4]   8.00-9.00   sec  2.27 GBytes  19.5 Gbits/sec    0   3.14 MBytes
[  4]   9.00-10.00  sec  2.05 GBytes  17.6 Gbits/sec    0   3.14 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  21.8 GBytes  18.7 Gbits/sec    0             sender
[  4]   0.00-10.00  sec  21.8 GBytes  18.7 Gbits/sec                  receiver


root@r2:~# ping -c 10 10.0.3.1
PING 10.0.3.1 (10.0.3.1) 56(84) bytes of data.
64 bytes from 10.0.3.1: icmp_seq=1 ttl=63 time=1.22 ms
64 bytes from 10.0.3.1: icmp_seq=2 ttl=63 time=0.901 ms
64 bytes from 10.0.3.1: icmp_seq=3 ttl=63 time=0.642 ms
64 bytes from 10.0.3.1: icmp_seq=4 ttl=63 time=0.673 ms
64 bytes from 10.0.3.1: icmp_seq=5 ttl=63 time=0.615 ms
64 bytes from 10.0.3.1: icmp_seq=6 ttl=63 time=0.803 ms
64 bytes from 10.0.3.1: icmp_seq=7 ttl=63 time=0.743 ms
64 bytes from 10.0.3.1: icmp_seq=8 ttl=63 time=0.596 ms
64 bytes from 10.0.3.1: icmp_seq=9 ttl=63 time=0.666 ms
64 bytes from 10.0.3.1: icmp_seq=10 ttl=63 time=0.680 ms

--- 10.0.3.1 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9014ms
rtt min/avg/max/mdev = 0.596/0.754/1.227/0.182 ms
```
We can see that we get an average bandwith of **18.7 Gbits/sec** and an average ping of **0.754ms**.

Now delay and package loss is added using tc.
```bash
tc qdisc add dev ens4 root netem delay 20ms loss 0.1%
```
```bash
root@r2:~# iperf3 -c 10.0.3.1
Connecting to host 10.0.3.1, port 5201
[  4] local 10.0.2.1 port 60082 connected to 10.0.3.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  1.46 MBytes  12.3 Mbits/sec    4   28.3 KBytes
[  4]   1.00-2.00   sec  2.33 MBytes  19.5 Mbits/sec    0   62.2 KBytes
[  4]   2.00-3.00   sec  2.80 MBytes  23.5 Mbits/sec    5   38.2 KBytes
[  4]   3.00-4.00   sec  2.55 MBytes  21.4 Mbits/sec    0   73.5 KBytes
[  4]   4.00-5.00   sec  4.41 MBytes  37.0 Mbits/sec    0    109 KBytes
[  4]   5.00-6.00   sec  4.85 MBytes  40.7 Mbits/sec    4    106 KBytes
[  4]   6.00-7.00   sec  4.85 MBytes  40.7 Mbits/sec    4    102 KBytes
[  4]   7.00-8.00   sec  4.35 MBytes  36.5 Mbits/sec    4    105 KBytes
[  4]   8.00-9.00   sec  5.78 MBytes  48.5 Mbits/sec    0    140 KBytes
[  4]   9.00-10.00  sec  3.98 MBytes  33.4 Mbits/sec   11   69.3 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  37.3 MBytes  31.3 Mbits/sec   32             sender
[  4]   0.00-10.00  sec  36.6 MBytes  30.7 Mbits/sec                  receiver

iperf Done.

root@r2:~# ping -c 10 10.0.3.1
PING 10.0.3.1 (10.0.3.1) 56(84) bytes of data.
64 bytes from 10.0.3.1: icmp_seq=1 ttl=63 time=21.4 ms
64 bytes from 10.0.3.1: icmp_seq=2 ttl=63 time=20.9 ms
64 bytes from 10.0.3.1: icmp_seq=3 ttl=63 time=21.0 ms
64 bytes from 10.0.3.1: icmp_seq=4 ttl=63 time=20.9 ms
64 bytes from 10.0.3.1: icmp_seq=5 ttl=63 time=21.0 ms
64 bytes from 10.0.3.1: icmp_seq=6 ttl=63 time=21.0 ms
64 bytes from 10.0.3.1: icmp_seq=7 ttl=63 time=21.0 ms
64 bytes from 10.0.3.1: icmp_seq=8 ttl=63 time=21.0 ms
64 bytes from 10.0.3.1: icmp_seq=9 ttl=63 time=21.0 ms
64 bytes from 10.0.3.1: icmp_seq=10 ttl=63 time=21.0 ms

--- 10.0.3.1 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9016ms
rtt min/avg/max/mdev = 20.941/21.071/21.473/0.192 ms
```
We can see that the bandwith has been reduced to only about **31 Mbits/sec** by just adding 0.1% of packet loss. The ping has been lifted to **21.071ms**, basically adding the 20ms delay configured.

Finally the delay/drop can be removed.
```bash
sudo tc qdisc del dev ens4 root
```
