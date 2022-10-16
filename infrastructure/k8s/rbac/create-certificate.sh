#!/bin/bash

set -x

openssl genrsa -out  capstone-project1-pod-user.key 2048
openssl req -new -key capstone-project1-pod-user.key -out capstone-project1-pod-user.csr -subj "/CN=capstone-project1-pod-user/O=capstone-project1"

# Replace the CSR in the csr.yaml
CSR=$(cat capstone-project1-pod-user.csr | base64 | tr -d '\n')
sed -i "s/__CSR___/${CSR}/g" capstone-project1-pod-user-csr.yaml
