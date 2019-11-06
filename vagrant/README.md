# gpu-demo

## Getting started

### Preparation

Get the source of this repo first:

```sh
git clone --recurse-submodules https://github.com/dholbach/gpu-demo
```

Then make sure you have, go 1.12, git and bazel installed. We'll assume
you run Ubuntu or Debian here for simplicity:

```sh
# Bazel first

echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
sudo apt-get install curl
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -

sudo apt-get update && sudo apt-get install bazel git snapd \
    vagrant virtualbox virtualbox-guest-dkms virtualbox-ext-pack
snap install go --channel 1.12/stable --classic
```
