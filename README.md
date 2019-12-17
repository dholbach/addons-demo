# gpu-demo

## What this is
In this brief demo we'd like to show easily you can bring up a cluster with
cluster addons. What you will get is:

- a cluster with two nodes (one controlplane, one worker) using VMs
- `kubeadm` bringing up the addon using the [proposed](https://github.com/kubernetes/kubernetes/compare/master...stealthybox:kubeadm-addon-installer) addon installer
- the gpu plugin deployed to the cluster as a daemonset

### What has been happening

The Cluster Addons sub-project of [SIG Cluster
Lifecycle](https://github.com/kubernetes/community/tree/master/sig-cluster-lifecycle)
brought together people from various areas of the Kubernetes landscape and produced
the following specifications and code:

- Addon Operators
  - [KEP Addons via Operators](https://github.com/kubernetes/enhancements/blob/master/keps/sig-cluster-lifecycle/addons/0035-20190128-addons-via-operators.md)
  - [CoreDNS addon operator](https://github.com/kubernetes-sigs/addon-operators/tree/master/coredns)
  - [kubebuilder support for addons](https://github.com/kubernetes-sigs/kubebuilder/pull/943)
- Addon Installer
  - [the installer itself](https://github.com/kubernetes-sigs/addon-operators/pull/25)
  - [KEP Installing Addons in Kubeadm](https://github.com/kubernetes/enhancements/pull/1308)
  - [Integration of addon installer in kubeadm](https://github.com/kubernetes/kubernetes/pull/85224)
  - Discussions about how to integrate into `kops` are underway.

Check out the [meeting minutes](https://docs.google.com/document/d/10_tl_SXcFGb-2109QpcFVrdrfnVEuQ05MBrXtasB0vk/edit) (and videos) for more details and please join the next meetings.

## Getting started

First make sure you have go 1.13, git and bazel installed. We'll assume
you run Ubuntu or Debian here for simplicity:

```sh
sudo apt install -y apt-transport-https git snapd curl docker.io vagrant vagrant-cachier virtualbox
sudo snap install go --channel 1.13/stable --classic
sudo snap install hub --classic

echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
sudo apt update
sudo apt install -y bazel
```

## Build `kubeadm` with Addons installer

We are going to build a [branch of `kubeadm`, which adds support for
addons](https://github.com/kubernetes/kubernetes/pull/85224).
How this can be used is described in [the KEP](https://github.com/stealthybox/enhancements/blob/20191013-install-addons-via-kubeadm/keps/sig-cluster-lifecycle/addons/20191013-install-addons-via-kubeadm.md#user-stories).

```sh
export GOPATH=~/go/
mkdir -p $GOPATH/src/github.com/kubernetes
cd $GOPATH/src/github.com/kubernetes/
git clone --single-branch https://github.com/kubernetes/kubernetes.git --depth 1
cd kubernetes
hub pr checkout 85224
GO111MODULE=on bazel build //cmd/kubeadm
```

## Start up cluster

Then get the source of this repo:

```sh
cd ~
git clone https://github.com/dholbach/gpu-demo
```

All you need to do for bring up is

```sh
cd gpu-demo
vagrant up
```

## What happens now

First of all, `vagrant` will bring up two VMs using `VirtualBox`, it will
install a whole raft of dependencies and make scripts, config and our build
of `kubeadm` and the GPU plugin available in the VMs, the network is
configured as well.

Relevant code:

- <https://github.com/dholbach/gpu-demo/blob/master/Vagrantfile>
- <https://github.com/dholbach/gpu-demo/blob/master/config/vm-prep.sh>

In a second step, our build of `kubeadm` is used to [bring up the
cluster](https://github.com/dholbach/gpu-demo/blob/master/config/kubeadm-init.sh).

> Note: the relevant commands to bring up the cluster can be seen
> [here](https://github.com/dholbach/gpu-demo/blob/master/config/kubeadm-init.sh#L27-L29).
>
> All that is required to bring up the cluster is a [simple cluster
> config](https://github.com/dholbach/gpu-demo/blob/master/cluster/config.yaml.template)
> that is passed to `kubeadm`.
>
> Here are the [addon related
> config](https://github.com/dholbach/gpu-demo/blob/master/cluster/config.yaml.template#L19-L25)
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
