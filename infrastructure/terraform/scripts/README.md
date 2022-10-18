# Supporting scripts for terraform

This folder has supporting scripts for terraform

**k8s-bootstrap-machines.sh**

This script will do the following:

1. Disable and turn off SWAP
2. Enable and Load Kernel modules
3. Add Kernel settings
4. Install docker runtime
5. Add apt repo for kubernetes
6. Install Kubernetes components (kubeadm, kubelet and kubectl), version = 1.20.12-00
7. Install Kubectl bash completion

We have to install version 1.20.12-00 because of the need to have Docker as 
the container engine (a requirement of thisproject)
Versions > 1.20 do not support Docker.

**k8s-start-controller.sh**

This script will do the following:

1. Start Kubernetes cluster
2. Setup kube config
3. Apply network driver (kube-flannel)
4. Apply metrics server components (customized version of k8s-metrics-server-v0.5.2-components.yaml)

**k8s-metrics-server-v0.5.2-components.yaml**

A customized version of k8s-metrics-server.
The customizations are to the startup arguments:
   - --kubelet-preferred-address-types=**InternalIP**
   - **--kubelet-insecure-tls**
