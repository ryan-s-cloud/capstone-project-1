#!/bin/bash

set -x

# Create temp folder
WORK_DIR=/tmp/etcd
[ -d ${WORK_DIR} ] || mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

# Create snapshot
ETCD_PKI_DIR=/etc/kubernetes/pki/etcd
sudo ETCDCTL_API=3 \
  etcdctl snapshot save snapshot.db   \
  --cacert ${ETCD_PKI_DIR}/ca.crt     \
  --cert   ${ETCD_PKI_DIR}/server.crt \
  --key    ${ETCD_PKI_DIR}/server.key
