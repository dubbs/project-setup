Vagrant.configure(2) do |config|
  #base
  #config.vm.box = "chef/centos-6.5"
  #config.vm.provision "shell", path: "provisioners/shell/yum-update.sh"
  #config.vm.provision "shell", path: "provisioners/shell/yum-repo.sh"
  #config.vm.provision "shell", path: "provisioners/shell/yum-kernel.sh"
  #config.ssh.insert_key = false
  #v1
  #config.vm.box = "v1"
  #config.vm.synced_folder ".", "/vagrant", disabled: true
  #config.vm.provision "shell", path: "provisioners/shell/vb-guest.sh"
  #config.ssh.insert_key = false
  #v1.0.1
  #config.vm.box = "v1.0.1"
  #config.vm.provision "shell", path: "provisioners/shell/httpd.sh"
  #config.vm.provision "shell", path: "provisioners/shell/php.sh"
  #config.ssh.insert_key = false
  #v1.0.2
  #config.vm.box = "v1.0.2"
  #config.vm.provision "shell", path: "provisioners/shell/mariadb.sh"
  #config.ssh.insert_key = false
  #v1.0.3
  #config.vm.box = "v1.0.3"
  #config.vm.provision "shell", path: "provisioners/shell/drush.sh"
  #config.vm.provision "shell", path: "provisioners/shell/drupal.sh"
  #config.ssh.insert_key = false
  #v1.0.4 - current
  #config.vm.box = "v1.0.4"
  #config.vm.network "private_network", ip: "192.168.33.10"
  #config.vm.synced_folder ".", "/vagrant", disabled: true
  #config.ssh.insert_key = false
  #dubbs/example
  config.vm.box = "dubbs/example"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.ssh.insert_key = false

  #config.vm.box_check_update = false
  #config.vm.provider "virtualbox" do |v|
    #v.memory = 1024
    #v.cpus = 2
  #end
end
