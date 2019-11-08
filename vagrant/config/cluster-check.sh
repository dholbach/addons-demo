#!/bin/sh

set -ex

# shellcheck source=/dev/null
. "./config/common.sh"

export NUM_CONTROLPLANE=1
export NUM_WORKERS=1

echo "Waiting for all nodes to join..."

NUM_EXPECTED="$(echo "$NUM_CONTROLPLANE+$NUM_WORKERS" | bc)"

if timeout 300 sh -c "
    until kubectl get nodes -oname | wc -l | grep ^$NUM_EXPECTED$
    do echo -n .; sleep 2
    done
    "
then echo "All nodes joined the cluster"
else echo "Timed out waiting for all nodes to join the cluster" 1>&2 && exit 1
fi

echo "Waiting for all nodes to be ready..."
if timeout 100 sh -c "
    while kubectl get nodes | grep NotReady
    do echo -n .; sleep 2
    done
    "
then echo "All nodes are now Ready"
else echo "Timed out waiting for all nodes to become Ready" 1>&2 && exit 2
fi

echo "Waiting for all pods to run..."
if timeout 100 sh -c "
    while kubectl get pods --all-namespaces | grep ContainerCreating
    do echo -n .; sleep 2
    done
    "
then echo "All pods are now running"
else echo "Timed out waiting for all pods to run" 1>&2 && exit 2
fi
