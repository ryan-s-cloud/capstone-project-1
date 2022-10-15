#!/bin/bash

echo "[TASK 1] Start Kubernetes cluster"
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

echo "[TASK 2] Setup kube config"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 3] Apply network driver"
# apply the network driver
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "[TASK 4] Apply metrics server components"
# apply the metrics server
kubectl apply -f /home/ubuntu/k8s-scripts/k8s-metrics-server-v0.5.2-components.yaml
