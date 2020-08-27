default_vagrantfile = "Vagrantfile.default"
load default_vagrantfile if File.exists?(default_vagrantfile)

Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory       = 8094
        vb.cpus         = 3
    end
end