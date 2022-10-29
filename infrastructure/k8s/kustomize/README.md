We use **Kustomize** to organize our k8s files.
Kustomize is a tool that helps us improve Kubernetes’ declarative object management with configuration files.
Kustomize has useful features that help with better organizing configuration files, managing
configuration variables, and support for deployment variants (like dev vs. prod environments).

Kustomize has the concept of bases and overlays. A base is a set of configs that can be reused
but not deployed on its own, and overlays are the actual configurations that use and extend the base and can be deployed.

We use two overlays: **dev** and **prod** for the DEV and PROD evironments, respectively.

**Usage:**

**For deploying to the DEV environment:**
```sh
cd ../..
kubectl apply -k k8s/kustomize/dev
```

**For deploying to the PROD environment:**
```sh
cd ../..
kubectl apply -k k8s/kustomize/prod
```

Notice the **-k**, which denotes usage of a Kustomize configuration
