## Create an account on [atlas](https://atlas.hashicorp.com/session)

## Create a Vagrant Box with the Web UI
name: dubbs/example
private: true

## Create a new box version
version: 1
description: example.com

## Create a new provider
provider: virtualbox
URL: https://vagrantcloud.com/chef/boxes/centos-6.5/versions/1.0.0/providers/virtualbox.box

## Release version
click `Edit` beside v1, then `Release version`

## Create Vagrantfile
```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "dubbs/example"
end
```

## Login to Vagrant Cloud, since box is private
vagrant login

## Initialize box
vagrant up

## Update box
vagrant ssh
su -
yum -y update

## Export updated box
vagrant package --output example.box

## Create new box version and provider on atlas
https://atlas.hashicorp.com/dubbs/boxes/example/versions/new
version: 1.0.1
provider: virtualbox
Upload: Continue to upload

## Upload in browser or with curl
https://atlas.hashicorp.com/help/vagrant/boxes/create

## curl
```bash
USERNAME=dubbs
BOX_NAME=example
VERSION=1.0.1
PROVIDER_NAME=virtualbox
ACCESS_TOKEN=9JJVBxMVhmhyqrNC5AMpojhAsoSyy8oJhYB7jkyYtyU20dh0fhMdi5mn7yxla2mvBOc
curl "https://atlas.hashicorp.com/api/v1/box/{$USERNAME}/{$BOX_NAME}/version/{$VERSION}/provider/{$PROVIDER_NAME}/upload?access_token={$ACCESS_TOKEN}"
```

## curl new box
# ran into issue where PUT failed, `curl --version`, was using SecureTransport
# so tried install new curl via brew, `brew install --with-openssl curl`, now using OpenSSL/1.0.2a
# just had to use new curl bin `/usr/local/Cellar/curl/7.41.0_1/bin/curl`
# update, I kept getting curl: (56) SSL read: error:00000000:lib(0):func(0):reason(0), errno 54, trying to upload to gdrive
# https://drive.google.com/file/d/0B6ohN-ATa3DYQzE3UUVLQmtsVHM/view?usp=sharing
curl -o output -# -X PUT --upload-file example.box https://binstore.hashicorp.com/3f44063f-ab7a-4a11-84a1-8582d8450c28

## Release version
click `Edit` beside v1.0.1, then `Release version`

## check outdated
vagrant box outdated












##Install Virtualbox
```bash
#4.3.18
sudo apt-get install virtualbox
#newest version
#wget http://download.virtualbox.org/virtualbox/4.3.28/virtualbox-4.3_4.3.28-100309~Ubuntu~raring_amd64.deb
#sudo dpkg -i virtualbox-4.3_4.3.28-100309~Ubuntu~raring_amd64.deb
#virtualbox --help
```

##Install Vagrant
```bash
wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
sudo dpkg -i vagrant_1.7.2_x86_64.deb 
vagrant version
```

##Install VM Box
```bash
vagrant box add chef/centos-6.5
vagrant init chef/centos-6.5
vagrant up
vagrant ssh
```

##Add host entry
```bash
192.168.33.10 example.com
```
