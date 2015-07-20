# prepare kernel for guest additions
yum -y update kernel
# http://wiki.centos.org/HowTos/Virtualization/VirtualBox/CentOSguest
# dkms so we dont need to reinstall Guest Additions after every kernel update
yum -y --enablerepo rpmforge install dkms
# install development environment and kernel source
yum -y groupinstall "Development Tools"
yum -y install kernel-devel
