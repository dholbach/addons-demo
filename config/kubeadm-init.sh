#!/bin/bash

set -ex

if [ "$(pwd)" != "$(realpath $(dirname $0))" ]; then
    echo "$(realpath $(dirname $0))"
    echo "cd into $(dirname $0) please"
    exit 1
fi

# shellcheck source=/dev/null
. "./common.sh"

export CLUSTER_CONFIG="$V_HOME/cluster/config.yaml"
CIDR_ESCAPE=$(echo "${POD_NETWORK_CIDR}" | sed -e 's/[\/&]/\\&/g')
export CIDR_ESCAPE

# Init the cluster
eth1_ip=$(ifconfig eth1 | awk '$1 == "inet" {print $2}')

sed "s/ETH1_IP/${eth1_ip}/g;
     s/POD_NETWORK_CIDR/${CIDR_ESCAPE}/g;
     s/TOKEN/${TOKEN}/g;" \
    "$CLUSTER_CONFIG".template > "$CLUSTER_CONFIG"

stat "$KUBECONFIG" || \
kubeadm init --config="$CLUSTER_CONFIG" && \
kubeadm init phase addon kube-proxy --config=<(sed "/AddonInstaller:/d" "$CLUSTER_CONFIG") && \
kubeadm init phase addon coredns --config=<(sed "/AddonInstaller:/d" "$CLUSTER_CONFIG")


# Make this control plane node able to run normal workloads
kubectl taint nodes --all node-role.kubernetes.io/master- || true # fails if already untainted
