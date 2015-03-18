EIEB Development Box
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
$ vagrant box add eieb-executor-x86_64 ../packer/eieb-executor-x86_64/eieb-executor-x86_64.virtualbox.box
```

```
$ make up
```

Packaging systemvm images installed vmimage
-------------------------------------------

```
$ vagrant ssh
```

```
cd /opt/axsh/eieb/makistrano/sysvm
time /usr/local/bin/maki prototyping deploy:download
# =~ 19min..5min

cd /opt/axsh/eieb/makistrano/hva
time /usr/local/bin/maki prototyping deploy:download
# =~ 1min

cd /opt/axsh/eieb/makistrano/cluster
time /usr/local/bin/maki prototyping deploy:download
# =~ 1min

cd /opt/axsh/eieb/makistrano/muscle
time /usr/local/bin/maki prototyping deploy:download
# =~ 1min

cd /opt/axsh/eieb/makistrano/hostvm/
time /usr/local/bin/maki prototyping deploy:download

history -c

exit
```

```
$ make package
```

```
$ vagrant box add --force eieb-executor-x86_64-1503 package.box
```
