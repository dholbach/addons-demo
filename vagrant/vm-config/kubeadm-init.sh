#!/bin/sh

set -ex

# shellcheck source=/dev/null
. "./vm-config/common.sh"

cat << EOF >> /etc/bash.bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf
alias k="kubectl"
alias ks="kubectl -n kube-system"
EOF

# Init the cluster
eth1_ip=$(ifconfig eth1 | awk '$1 == "inet" {print $2}')

stat "$KUBECONFIG" || \
kubeadm config images pull && \
kubeadm init phase preflight && \
kubeadm init phase kubelet-start && \
kubeadm init phase certs all \
    --kubernetes-version "${KUBE_VERSION}" \
    --apiserver-advertise-address "${eth1_ip}" && \
kubeadm init phase kubeconfig all \
    --kubernetes-version "${KUBE_VERSION}" \
    --apiserver-advertise-address "${eth1_ip}" && \
kubeadm init phase control-plane all && \
kubeadm init phase etcd local && \
kubeadm init phase upload-certs --upload-certs --v=5 &&\
kubeadm init phase mark-control-plane && \
cd "${CONFIG_DIR}/cluster/" && kubeadm init phase addon installer \
    --config "config.yaml" --v=5 && \
kubeadm init phase upload-config all --v=5 && \
kubeadm init \
    --skip-phases preflight,kubelet-start,certs,kubeconfig,control-plane,etcd,upload-certs,mark-control-plane,addon,upload-config \
    --token abcdef.0123456789abcdef \
    --pod-network-cidr "${POD_NETWORK_CIDR}" && \
kubeadm init phase addon kube-proxy \
    --apiserver-advertise-address "${eth1_ip}" --v=5 && \
kubeadm init phase addon coredns


# Install Weave Net as the Pod networking solution
# Workaround  https://github.com/weaveworks/weave/issues/3700
### kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 -w0)"
kubectl apply -f "https://raw.githubusercontent.com/weaveworks/weave/master/prog/weave-kube/weave-daemonset-k8s-1.9.yaml"

# Make this control plane node able to run normal workloads
kubectl taint nodes --all node-role.kubernetes.io/master- || true # fails if already untainted
