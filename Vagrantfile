Vagrant.configure(2) do |config|
  # vbase
  #config.vm.box = "chef/centos-6.5"
  # v1 - guest additions
  #config.vm.box = "v1"
  # v1.0.1 - update and httpd
  config.vm.box = "v1.0.1"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provision "shell", path: "provisioners/shell/httpd.sh"

  #config.vm.synced_folder ".", "/vagrant", disabled: true
  #config.vm.box = "centos-6.5-drupal-7.38"
  #config.vm.box_check_update = false
  #config.vm.provider "virtualbox" do |v|
    #v.memory = 1024
    #v.cpus = 2
  #end
end
