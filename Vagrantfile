# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.

  config.vm.define "servernginx" do |servernginx|
    servernginx.vm.box = "debian/bullseye64"
    servernginx.vm.hostname = "AbelMonNginx"
    servernginx.vm.network "private_network", ip:"192.168.10.10",
        virtualbox__intnet: "nginx"
        servernginx.vm.network "private_network", ip: "192.168.21.21",
        virtualbox__intnet: "sql"
        servernginx.vm.synced_folder "./","/vagrant"
        #servernginx.vm.network "public_network"
        servernginx.vm.provision "shell", path: "scripte.sh"

  end

  config.vm.define "servernginx2" do |servernginx2|
    servernginx2.vm.box = "debian/bullseye64"
    servernginx2.vm.hostname = "AbelMonNginx2"
    servernginx2.vm.network "private_network", ip:"192.168.10.11", # red con balanc
          virtualbox__intnet: "nginx"
        servernginx2.vm.network "private_network", ip: "192.168.21.30", # red con mysql
          virtualbox__intnet: "sql"
        servernginx2.vm.synced_folder "./","/vagrant"
        #servernginx2.vm.network "public_network"
        servernginx2.vm.provision "shell", path: "scripte.sh"

  end
    
    #definimos scripte para hacer referencia a nginx y m para mysql

  
  config.vm.define "serversql" do |serversql|
    serversql.vm.box = "debian/bullseye64"
    serversql.vm.hostname = "AbelMonMYSQL"
    #serversql.vm.network "public_network"
    serversql.vm.network "private_network", ip: "192.168.21.22",
                  virtualbox__intnet: "sql"
    serversql.vm.synced_folder "./","/vagrant"
    serversql.vm.provision "shell", path: "scriptm.sh"
  # sudo ip route del default para quita la puerta de enlace

  end

  config.vm.define "balanceador" do |balanceador|
    balanceador.vm.box = "debian/bullseye64"
    balanceador.vm.hostname = "AbelMonBalan"
    balanceador.vm.network "public_network"
    balanceador.vm.network "private_network", ip: "192.168.10.12",
          virtualbox__intnet: "nginx"
    balanceador.vm.synced_folder "./","/vagrant"
    balanceador.vm.provision "shell", path: "scripte.sh"

  end


  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
