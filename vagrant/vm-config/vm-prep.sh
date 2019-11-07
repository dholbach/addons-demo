#!/bin/sh

set -ex

# shellcheck source=/dev/null
. "./vm-config/common.sh"

export apt_docker="18.09.7-0ubuntu1~18.04.4"
export apt_k8s="1.16.2-00"
export DEBIAN_FRONTEND="noninteractive"

if [ -f "$PATCHED_KUBEADM" ]; then
    cp "$PATCHED_KUBEADM" /usr/local/bin
    chmod a+x /usr/local/bin/kubeadm
else
    echo "kubeadm not found."
    exit 1
fi

if [ -f "$CONFIG_DIR/10-kubeadm.conf" ]; then
    if [ ! -d /etc/systemd/system/kubelet.service.d/ ]; then
        mkdir -p /etc/systemd/system/kubelet.service.d/
    fi
    cp "$CONFIG_DIR/10-kubeadm.conf" /etc/systemd/system/kubelet.service.d/
else
    echo "kubeadm.conf not found."
    exit 1
fi

apt='apt-get -q'

# Make sure curl and apt SSL support is available
${apt} update && ${apt} install -y apt-transport-https curl

# Add the Kubernetes apt signing key and repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# Install kubelet, kubectl and docker (kubernetes-cni and cri-tools are deps of kubeadm)
${apt} update && \
${apt} install -y \
    docker.io="$apt_docker" kubelet="$apt_k8s" \
    kubectl="$apt_k8s" kubernetes-cni cri-tools

# Disable swap, it must not be used when Kubernetes is running
swapoff -a
sed -i /swap/d /etc/fstab

# Enable the docker systemd service
systemctl enable docker.service

# Pre-configure the kubelet to bind to eth1
#   ref: https://github.com/kubernetes/kubeadm/issues/203#issuecomment-335416377
eth1_ip=$(ifconfig eth1 | awk '$1 == "inet" {print $2}')
if [ ! -d /etc/systemd/system/kubelet.service.d/ ]; then mkdir -p /etc/systemd/system/kubelet.service.d/; fi
echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${eth1_ip}\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Route the cluster CIDR via eth1
#   ref: https://github.com/kubernetes/kubeadm/issues/102#issuecomment-291532883
cat << EOF > /etc/netplan/90-k8s-services-eth1.yaml
---
network:
  version: 2
  ethernets:
    eth1:
      routes:
        - to: 10.96.0.0/16
          via: 0.0.0.0
EOF
netplan apply
