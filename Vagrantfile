# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.network :forwarded_port, guest: 3306, host: 3306
  config.vm.network :forwarded_port, guest: 9631, host: 9631
  config.vm.network :forwarded_port, guest: 3000, host: 3001
  config.vm.network :forwarded_port, guest: 4000, host: 4001
  config.vm.network :forwarded_port, guest: 80, host: 3080
  config.vm.network :forwarded_port, guest: 82, host: 3082
  config.vm.provision "main-install",type: :shell, :path => "script/vagrant/install.sh"
  config.vm.provision "mysql-install",type: :shell, :path => "script/vagrant/mysql-install.sh"
  config.vm.provision "apache-install",type: :shell, :path => "script/vagrant/apache-install.sh"
  config.vm.provision "hab-install", type: :shell, :path => "script/vagrant/hab-install.sh"
  config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777", "fmode=777"]
  config.vm.synced_folder "~/icts/sparc-fulfillment", "/fulfillment", :mount_options => ["dmode=777", "fmode=777"]
  config.vm.synced_folder "~/.hab", "/home/vagrant/.hab"
  config.vm.network "private_network", ip: "33.33.33.10", type: "dhcp", auto_config: false

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end
end
