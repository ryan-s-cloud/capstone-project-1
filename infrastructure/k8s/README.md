# Kubernetes related files

This folder has all k8s related files:

**etcd-snapshot:**

Contains scripts to download etcdctl and create etcd snapshots

**kustomize:**

**Main** resources to deploy app to kubernetes. Includes everything needed: network policy, HSA, deployment, service, etc.

It is organized the **Kustomize** way.


**rbac:**

Contains scripts and yaml file to create pod user. Includes certificate generation, role,
role binding files.
