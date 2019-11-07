#!/bin/bash

set -ex
# Join the cluster asynchronously
nohup sh -c "
    until kubeadm join \\
    --token abcdef.0123456789abcdef \\
    --discovery-token-unsafe-skip-ca-verification \\
    192.168.5.#{10 + 1}:6443
    do sleep 2
    done
" >> /var/log/kubeadm_join_async.log 2>&1 & disown
