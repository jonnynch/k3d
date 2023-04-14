# Install Kubernetes Dashboard 
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
k apply -f kubernetes-dashboard/sa.yaml
k apply -f kubernetes-dashboard/crb.yaml

kubectl create ingress kubernetes-dashboard --class=nginx \
--rule="kubernetes-dashboard.localdev.me/*=kubernetes-dashboard:443" \
--annotation nginx.ingress.kubernetes.io/backend-protocol=HTTPS \
--annotation nginx.ingress.kubernetes.io/ssl-passthrough=true \
--annotation nginx.ingress.kubernetes.io/ssl-redirect=true  \
-n kubernetes-dashboard
```

## Access the dashboard 

via https://kubernetes-dashboard.localdev.me
### Access Token can be retrieved by
```
kubectl -n kubernetes-dashboard create token admin-user
```
