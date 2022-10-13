#!/bin/bash

echo "[TASK 1] Disable and turn off SWAP"
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

echo "[TASK 2] Enable and Load Kernel modules"
sudo tee /etc/modules-load.d/containerd.conf >/dev/null <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo "[TASK 3] Add Kernel settings"
sudo tee /etc/sysctl.d/kubernetes.conf >/dev/null <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system >/dev/null 2>&1

echo "[TASK 4] Install docker runtime"
sudo apt update -qq -y >/dev/null 2>&1
# install pre-requisites
sudo apt install -qq -y apt-transport-https curl git
# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |\
sudo apt-key add -add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -qq -y
sudo apt install -qq -y docker.io
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

echo "[TASK 5] Add apt repo for kubernetes"
# install kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sudo mv ~/kubernetes.list /etc/apt/sources.list.d
sudo apt update -qq -y

echo "[TASK 6] Install Kubernetes components (kubeadm, kubelet and kubectl)"
sudo apt-get install -qq -y kubeadm=1.20.12-00 kubelet=1.20.12-00 kubectl=1.20.12-00
sudo apt-mark hold kubeadm kubelet kubectl

echo "[TASK 7] Install Kubectl bash completion"
sudo apt install -qq -y bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
