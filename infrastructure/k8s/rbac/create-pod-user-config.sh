#!/bin/bash

set -x

user='capstone-project1-pod-user'
namespace='capstone-project1'

sed s/kubernetes-admin/${user}/g ~/.kube/config |\
sed s/@kubernetes/@${namespace}/g |\
sed "s/client-certificate-data:.*$/client-certificate-data: $(kubectl get csr ${user} -o jsonpath={.status.certificate})/g" |\
sed "s/client-key-data:.*$/client-key-data: $(cat ${user}.key | base64 | tr -d '\n')/g" \
  > ${user}.conf

# permission denied
kubectl --kubeconfig=${user}.conf get pods -A

# permission should be OK
kubectl --kubeconfig=${user}.conf get pods -n ${namespace}
