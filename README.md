# gpu-demo

## Prep

First make sure you have go 1.12, git and bazel installed. We'll assume
you run Ubuntu or Debian here for simplicity:

```sh
sudo apt install -y apt-transport-https git snapd curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -

sudo apt update
sudo apt install -y kubectl bazel

snap install go --channel 1.12/stable --classic
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
mkdir -p $GOPATH/src/github.com/stealthybox
cd $GOPATH/src/github.com/stealthybox/
git clone --single-branch --branch kubeadm-addon-installer https://github.com/stealthybox/kubernetes.git --depth 1
cd kubernetes
GO111MODULE=on bazel build //cmd/kubeadm
```

## Start up cluster

Use [vagrant](./vagrant/).
