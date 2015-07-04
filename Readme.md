##Install Virtualbox
```bash
wget http://download.virtualbox.org/virtualbox/4.3.28/virtualbox-4.3_4.3.28-100309~Ubuntu~raring_amd64.deb
sudo dpkg -i virtualbox-4.3_4.3.28-100309~Ubuntu~raring_amd64.deb
virtualbox --help
```

##Install Vagrant
```bash
wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
sudo dpkg -i vagrant_1.7.2_x86_64.deb 
vagrant version
```

##Install VM Box
```
vagrant box add chef/centos-6.5
vagrant init chef/centos-6.5
vagrant up
vagrant ssh
```
