## create a base box

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "chef/centos-6.5"
end
```

## install package repos
```bash
vagrant ssh
su -
# get lastest epel from https://fedoraproject.org/wiki/EPEL
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
rpm -ivh epel-release-latest-6.noarch.rpm
# get latest rpmforge from http://pkgs.repoforge.org/rpmforge-release/
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
```

## install virtualbox guest additions
```bash
# update kernel so kernel-devel matches
yum -y update kernel
# http://wiki.centos.org/HowTos/Virtualization/VirtualBox/CentOSguest
# dkms so we dont need to reinstall Guest Additions after every kernel update
yum -y --enablerepo rpmforge install dkms
# install development environment and kernel source
yum -y groupinstall "Development Tools"
yum -y install kernel-devel
# reload to get new kernel version
vagrant reload
# find latest iso http://download.virtualbox.org/virtualbox/4.3.30/
wget http://download.virtualbox.org/virtualbox/4.3.30/VBoxGuestAdditions_4.3.30.iso
mkdir -p /mnt/iso
mount -t iso9660 -o loop VBoxGuestAdditions_4.3.30.iso /mnt/iso
cd /mnt/iso
./VBoxLinuxAdditions.run
cd
umount /mnt/iso
```

## add public key before package
```bash
# https://github.com/mitchellh/vagrant/issues/5186#issuecomment-81409295
wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O .ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
chown -R vagrant:vagrant .ssh
```

## package vm
vagrant package --output v1.box
vagrant box add v1 v1.box

## update vagrantfile
```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "v1"
  config.ssh.insert_key = false
end
```

