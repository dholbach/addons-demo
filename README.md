# gpu-demo

## Prep

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

```sh
export GOPATH=~/go/
mkdir -p $GOPATH/src/github.com/kubernetes
cd $GOPATH/src/github.com/kubernetes/
git clone https://github.com/kubernetes/kubernetes.git
cd kubernetes
git checkout v1.16.2
curl -s https://github.com/kubernetes/kubernetes/compare/master...stealthybox:kubeadm-addon-installer.diff -o addons.diff
patch -p1 < addons.diff
# XXX: fix patch to apply
GO111MODULE=on bazel build //cmd/kubeadm
```

## Start up cluster

Use [vagrant](./vagrant/).
