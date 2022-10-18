# Create a POD user

The pod user's role allows for **create,list,get,update,delete pods*
in the **capstone-project1** namespace


```sh
kubectl apply -f capstone-project1-pod-user-csr.yaml
kubectl get csr

kubectl certificate approve capstone-project1-pod-user

# wait a few seconds for approval of the CSR

kubectl apply -f capstone-project1-role.yaml

kubectl get roles -n capstone-project1

kubectl apply -f capstone-project1-roleBinding.yaml

kubectl get rolebindings -n capstone-project1

kubectl describe rolebinding capstone-project1-pod-role-rolebinding -n capstone-project1

kubectl auth can-i list pods --as capstone-project1-pod-user -n capstone-project1

kubectl auth can-i create pods --as capstone-project1-pod-user -n capstone-project1
```
