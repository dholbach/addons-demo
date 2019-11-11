Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus   = "2"
    vb.memory = "2048"
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  v_HOME          = "/home/vagrant"
  v_CONFIG        = "#{v_HOME}/config"
  v_CLUSTER       = "#{v_HOME}/cluster"
  LOCAL_DIR       = File.expand_path("./")
  L_CONFIG        = File.join(LOCAL_DIR, "config")

  # Make patch kubeadm available
  config.vm.synced_folder \
    "~/go/src/github.com/kubernetes/kubernetes/bazel-bin/cmd/kubeadm/linux_amd64_pure_stripped", \
    "#{v_HOME}/kubeadm"

  # add some additional config and scripts
  config.vm.synced_folder "#{LOCAL_DIR}/cluster", v_CLUSTER
  config.vm.synced_folder "#{LOCAL_DIR}/config", v_CONFIG

  config.vm.provision "shell", privileged: true, path: "#{L_CONFIG}/vm-prep.sh"

  num_controlplane = 1 # at the moment, scripts only support 1
  num_workers      = 1

  kubeadm_join_async = <<~SHELL
    set -ex
    # Join the cluster asynchronously
    source #{v_CONFIG}"/common.sh"
    nohup sh -c "
      until kubeadm join \\
        --token ${TOKEN} \\
        --discovery-token-unsafe-skip-ca-verification \\
        192.168.5.#{10 + 1}:6443
      do sleep 2
      done
    " >> /var/log/kubeadm_join_async.log 2>&1 & disown
  SHELL

  (1..num_workers).each do |i|
    config.vm.define "worker-#{i}" do |worker|
      worker.vm.hostname = "worker-#{i}"
      worker.vm.network "private_network", ip: "192.168.5.#{100 + i}"
      worker.vm.provision "shell", inline: kubeadm_join_async
    end
  end

  (1..num_controlplane).each do |i|
    config.vm.define "controlplane-#{i}" do |controlplane|
      controlplane.vm.hostname = "controlplane-#{i}"
      controlplane.vm.network "private_network", ip: "192.168.5.#{10 + i}"
      controlplane.vm.provision "shell", inline: "cd #{v_CONFIG}; ./kubeadm-init.sh"
      controlplane.vm.provision "shell", path: "#{L_CONFIG}/cluster-check.sh"
    end
  end
end
