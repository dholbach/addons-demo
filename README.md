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
  - [Integration of addon installer in kubeadm](https://github.com/kubernetes/kubernetes/compare/master...stealthybox:kubeadm-addon-installer)
  - Discussions about how to integrate into `kops` are underway.

Check out the [meeting minutes](https://docs.google.com/document/d/10_tl_SXcFGb-2109QpcFVrdrfnVEuQ05MBrXtasB0vk/edit) (and videos) for more details and please join the next meetings.

## Getting started

First make sure you have go 1.12, git and bazel installed. We'll assume
you run Ubuntu or Debian here for simplicity:

```sh
sudo apt install -y apt-transport-https git snapd curl make docker.io
snap install go --channel 1.12/stable --classic

echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
sudo apt update
sudo apt install -y bazel
```

Then get the source of this repo:

```sh
git clone --recurse-submodules https://github.com/dholbach/gpu-demo
```

Now build the gpu plugin:

```sh
cd gpu-demo/intel-device-plugins-for-kubernetes
make intel-gpu-plugin
```

## Build `kubeadm` with Addons installer

We are going to build a branch of `kubeadm`, which adds support for addons.
How this can be used is described in [the KEP](https://github.com/stealthybox/enhancements/blob/20191013-install-addons-via-kubeadm/keps/sig-cluster-lifecycle/addons/20191013-install-addons-via-kubeadm.md#user-stories).

```sh
export GOPATH=~/go/
mkdir -p $GOPATH/src/github.com/kubernetes
cd $GOPATH/src/github.com/kubernetes/
git clone --single-branch --branch 1.16.2-plus-kubeadm-addon-installer https://github.com/dholbach/kubernetes.git --depth 2
GO111MODULE=on bazel build //cmd/kubeadm
```

## Start up cluster

Use [vagrant](./vagrant/).
