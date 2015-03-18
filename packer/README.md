Packer Vagrant Templates
========================

This repository contains templates for CentOS/Fedora that can create Vagrant base boxes using Packer.

Current Boxes
-------------

64-bit boxes:

+ centos-6.6-x86_64 (centos minimal)
+ eieb-executor-x86_64 (minimal + jenkins)

32-bit boxes:

+ ...

Requirements
------------

+ Packer (>= 0.7.5)(http://www.packer.io/downloads.html)
+ Vagrant (>= 1.6.5)(http://www.vagrantup.com/downloads.html)
+ Platforms
  + Virtualbox (>= 4.3.20)(https://www.virtualbox.org/wiki/Downloads)
  + VMware Workstaion (>= 10)(https://www.vmware.com/go/downloadworkstation)
+ Vagrant VMware plugin if you're using vmware (http://www.vagrantup.com/vmware)

Build Vagrant Base Box
----------------------

A GNU Make `Makefile` drives the process via the following targets:

```
$ make build # Build the box
$ make test  # Run tests
$ make clean # Clean up stamp files
```

### Makefile variable(s)

The variable(s) can be currently used are:

+ PROVIDER

Possible values for the PROVIDER are:

+ virtualbox (default)
+ vmware

If you build the vagrant base box for vmware, the value of `PROVIDER` should be `vmware`. For example with vmware:

```
$ make build PROVIDER=vmware
$ make test  PROVIDER=vmware
```

### Folder Structure

```
project/
|  +- Makefile      # Symbolic link of ../common/Makefile
|  +- ks.cfg        # Minimal base box build scenario
|  +- template.json # Packer template
|  +- Vagrantfile   # Copy of ../templates/Vagrantfile
|
+- common/
|  +- Makefile
|  +- scripts/
|     +- setup.sh
|     +--- bootstrap.sh
|     +--- sshd_config.sh
|     +--- vagrant.guest.account.sh
|     +--- virtualbox.guest.additions.sh
|     +--- vmware-tools.sh
|     +- teardown.sh
|
+- templates/
   +- Vagrantfile
   +- ks.6.cfg # Kickstart config for CentOS-6.x
```
