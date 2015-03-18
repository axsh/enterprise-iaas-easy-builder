EIEB Evaluation Box
====================

Requirements
------------

+ Vagrant (>= 1.6.5)(http://www.vagrantup.com/downloads.html)
+ Platforms
  + Virtualbox (>= 4.3.20)(https://www.virtualbox.org/wiki/Downloads)
  + VMware Workstaion (>= 10)(https://www.vmware.com/go/downloadworkstation)
+ Vagrant VMware plugin if you're using vmware (http://www.vagrantup.com/vmware)

Getting Started
---------------

```
$ vagrant up
```

Physical Setup Manaual
----------------------

### System Diagram

+ eth0 (vagrant reserved)
+ eth1 public
+ eth2 storage
+ eth3 management

```
       ~~~
        |
       HOST
        |
+-------|-------+
| o o o o o o o | (nat)
+---|-----------+
    |
    | +-------------+
    | | o o o o o o | (intnet)
    | +-|-----|---|-+
    |   |     |   |
+---|---|-----|---|----------------+
|   |   |     |   |     (LinuxBox) |
| eth0 eth1 eth2 eth3              |
|       |     |   |                |
|       |     |  ~~~               |
|       |    ~~~                   |
|       |                          |
|       |    +---+                 |
|       |    |brX|                 |
|       |    | o |                 |
|       +------o |                 |
|            | o |                 |
|            | o--- lowX           |
|            | o |                 |
|            +---+                 |
|                                  |
+----------------------------------+
```

### NIC Configuration

```
# vi /etc/sysconfig/network-scripts/ifcfg-eth1
```

```
DEVICE=eth1
TYPE=Ethernet
BOOTPROTO=none
#HWADDR=
ONBOOT=yes
BRIDGE=brpub
```

```
# vi /etc/sysconfig/network-scripts/ifcfg-eth2
```

```
DEVICE=eth2
TYPE=Ethernet
BOOTPROTO=none
#HWADDR=
ONBOOT=yes
BRIDGE=brstr
```

```
# vi /etc/sysconfig/network-scripts/ifcfg-eth3
```

```
DEVICE=eth3
TYPE=Ethernet
BOOTPROTO=none
#HWADDR=
ONBOOT=yes
BRIDGE=brmng
```

#### Bridge Interface

```
# vi /etc/sysconfig/network-scripts/ifcfg-brpub
```

```
DEVICE=brpub
TYPE=Bridge
BOOTPROTO=static
IPADDR=172.16.8.41
NETMASK=255.255.252.0
ONBOOT=yes
```

```
# vi /etc/sysconfig/network-scripts/ifcfg-brstr
```

```
DEVICE=brstr
TYPE=Bridge
BOOTPROTO=static
IPADDR=172.16.6.41
NETMASK=255.255.255.0
ONBOOT=yes
```

```
# vi /etc/sysconfig/network-scripts/ifcfg-brmng
```

```
DEVICE=brmng
TYPE=Bridge
BOOTPROTO=static
IPADDR=172.16.7.41
NETMASK=255.255.255.0
ONBOOT=yes
```

#### Tap Interface

```
# vi /etc/sysconfig/network-scripts/ifcfg-lowpub
```

```
DEVICE=lowpub
TYPE=Tap
BRIDGE=brpub
BOOTPROTO=none
MACADDR=00:00:00:14:00:1e
ONBOOT=yes
```

```
# vi /etc/sysconfig/network-scripts/ifcfg-lowstr
```

```
DEVICE=lowstr
TYPE=Tap
BRIDGE=brstr
BOOTPROTO=none
MACADDR=00:00:00:14:00:1f
ONBOOT=yes
```

```
# vi /etc/sysconfig/network-scripts/ifcfg-lowmng
```

```
DEVICE=lowmng
TYPE=Tap
BRIDGE=brmng
BOOTPROTO=none
MACADDR=00:00:00:14:00:1d
ONBOOT=yes
```

### Disable SELinux

```
# sed -i 's,^SELINUX=.*,SELINUX=disabled,' /etc/selinux/config
```

### Iptables Rules

```
# vi /etc/sysconfig/iptables
```

```
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
#
-A INPUT -i brpub -d 172.16.8.0/24 -j REJECT
-A INPUT -i brstr -d 172.16.6.0/24 -j REJECT
-A INPUT -i brmng -d 172.16.7.0/24 -j REJECT
COMMIT
```

```
# chkconfig iptables on
# service iptables restart
```

### Account

```
# groupadd eieb
# useradd -g eieb eieb
```

```
# visudo
```

```
> eieb ALL=(ALL) NOPASSWD: ALL
```

### SSH Keypair Deployment

```
# mkdir -m 700 /home/eieb/.ssh
# vi /home/eieb/.ssh/authorized_keys
```

```
(paste)
```

```
# chmod 644 /home/eieb/.ssh/authorized_keys
```

```
# chown -R eieb:eieb /home/eieb/
```
