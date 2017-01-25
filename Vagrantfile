Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-16.04-lts-i386"
  config.vm.box_url = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-i386-vagrant.box"

  config.vm.network "forwarded_port", guest: 8090, host: 8090

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "data", "/data", owner: "daemon", group: "daemon", create: true

  config.vm.provision "shell", path: "setup.sh"

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.memory = 1486
  end
end
