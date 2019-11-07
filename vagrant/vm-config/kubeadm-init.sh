#!/bin/sh

set -ex

# shellcheck source=/dev/null
. "./vm-config/common.sh"

# Configure kubectl for the kubeadm kubeconfig
export KUBECONFIG=/etc/kubernetes/admin.conf

cat << EOF >> /etc/bash.bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf
alias k="kubectl"
alias ks="kubectl -n kube-system"
EOF

# Init the cluster
eth1_ip=$(ifconfig eth1 | awk '$1 == "inet" {print $2}')

stat $KUBECONFIG || \
kubeadm init phase addon installer --feature-gates AddonInstaller=true && \
kubeadm init phase addon installer --config cluster/config.yaml && \
kubeadm init --v=5 \
--kubernetes-version "${KUBE_VERSION}" \
--apiserver-advertise-address "${eth1_ip}" \
--pod-network-cidr 10.96.0.0/16 \
--token abcdef.0123456789abcdef

# Install Weave Net as the Pod networking solution
# Workaround  https://github.com/weaveworks/weave/issues/3700
### kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 -w0)"
kubectl apply -f "https://raw.githubusercontent.com/weaveworks/weave/master/prog/weave-kube/weave-daemonset-k8s-1.9.yaml"

# Make this control plane node able to run normal workloads
kubectl taint nodes --all node-role.kubernetes.io/master- || true # fails if already untainted
