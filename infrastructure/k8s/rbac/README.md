# Create a POD user

The pod user's role allows for **create,list,get,update,delete** pods
in the **capstone-project1** namespace

**usage:**

**Via scripts:**

```sh
sh ./create-certificate.sh
sh ./apply.sh
# To create user's config and test using kubectl
sh ./create-pod-user-config.sh
```

**Or manually:**

```sh

# Generate key and CSR of the certificate for the pod user
openssl genrsa -out  capstone-project1-pod-user.key 2048
openssl req -new -key capstone-project1-pod-user.key -out capstone-project1-pod-user.csr -subj "/CN=capstone-project1-pod-user/O=capstone-project1"

# Replace the CSR in the csr.yaml
CSR=$(cat capstone-project1-pod-user.csr | base64 | tr -d '\n')
sed -i "s/__CSR___/${CSR}/g" capstone-project1-pod-user-csr.yaml

# Request k8s to sign our CSR
kubectl apply -f capstone-project1-pod-user-csr.yaml
kubectl get csr
kubectl certificate approve capstone-project1-pod-user

# wait a few seconds for approval of the CSR

kubectl apply -f capstone-project1-role.yaml

kubectl get roles -n capstone-project1

kubectl apply -f capstone-project1-roleBinding.yaml

kubectl get rolebindings -n capstone-project1

kubectl describe rolebinding capstone-project1-pod-role-rolebinding -n capstone-project1

# check if user has access to list pods
kubectl auth can-i list pods --as capstone-project1-pod-user -n capstone-project1

# check if user has access to create pods
kubectl auth can-i create pods --as capstone-project1-pod-user -n capstone-project1
```
