# gpu-demo using kinder

Prep:

```sh
sudo apt install -y apt-transport-https git snapd
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

snap install go/1.12
```

Get `kinder`:

```sh
git clone https://github.com/kubernetes/kubeadm.git
cd kubeadm/kinder
GO111MODULE=on go install
```

Build node image using our custom `kubeadm` build:

```sh
kinder build node-variant \
    --with-kubeadm ~/go/src/github.com/kubernetes/kubernetes/bazel-bin/cmd/kubeadm/linux_amd64_pure_stripped/kubeadm \
    --base-image kindest/node:v1.16.2
```

If successful, it will give you the sha of the image it built. In our case `084f648ad40806835f84cf435bc9c1ccc014f5c84127e7ee0dea3d2b4b6cdadf`:

```sh
kinder create cluster \
    --image sha256:084f648ad40806835f84cf435bc9c1ccc014f5c84127e7ee0dea3d2b4b6cdadf \
    --worker-nodes 1
```

To init the controlplane and let the worker join, we run:

```sh
kinder do kubeadm-init
kinder do kubeadm-join
```

Now you can access your cluster:

```sh
export KUBECONFIG=~/.kube/kind-config-kind
kubectl get all --all-namespaces
```
