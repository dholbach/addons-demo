# gpu-demo

## Preparation

Install vagrant et al:

```sh
sudo apt update && sudo apt-get install vagrant vagrant-cachier virtualbox
```

## Starting the cluster

All you need to do here is:

```sh
vagrant up
```

## What happens now

First of all, `vagrant` will bring up two VMs using `VirtualBox`, it will
install a whole raft of dependencies and make scripts, config and our build
of `kubeadm` and the GPU plugin available in the VMs, the network is
configured as well.

Relevant code:

- <https://github.com/dholbach/gpu-demo/blob/master/vagrant/Vagrantfile>
- <https://github.com/dholbach/gpu-demo/blob/master/vagrant/config/vm-prep.sh>

In a second step, our build of `kubeadm` is used to [bring up the
cluster](https://github.com/dholbach/gpu-demo/blob/master/vagrant/config/kubeadm-init.sh).

> Note: the relevant commands to bring up the cluster can be seen
> [here](https://github.com/dholbach/gpu-demo/blob/master/vagrant/config/kubeadm-init.sh#L27-L29).
>
> All that is required to bring up the cluster is a [simple cluster
> config](https://github.com/dholbach/gpu-demo/blob/master/vagrant/cluster/config.yaml.template)
> that is passed to `kubeadm`.
>
> Here are the [addon related
> config](https://github.com/dholbach/gpu-demo/blob/master/vagrant/cluster/config.yaml.template#L19-L22)
> bits.

## Checking in on the cluster

To verify all is working as intended, all you need to do is:

```sh
$ vagrant ssh controlplane-1 -- -tt sudo bash
root@controlplane-1:~# kubectl get pods -n kube-system
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-5644d7b6d9-fx27j                 1/1     Running   0          5m35s
coredns-5644d7b6d9-r7w8f                 1/1     Running   0          5m35s
etcd-controlplane-1                      1/1     Running   0          4m46s
intel-gpu-plugin-ghsdk                   1/1     Running   0          3m54s
intel-gpu-plugin-lmlv8                   1/1     Running   0          5m4s
kube-apiserver-controlplane-1            1/1     Running   0          4m44s
kube-controller-manager-controlplane-1   1/1     Running   0          4m43s
kube-proxy-bpccd                         1/1     Running   0          5m14s
kube-proxy-ncm8m                         1/1     Running   0          5m36s
kube-scheduler-controlplane-1            1/1     Running   0          4m33s
weave-net-8td8g                          2/2     Running   0          5m36s
weave-net-fwzbj                          2/2     Running   1          5m14s
root@controlplane-1:~#
```
