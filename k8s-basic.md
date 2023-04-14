
# Kubernetes Basic - build/import image, start pod and do port forward
## docker: Build image
```
cd hello-world/nginx
docker build --tag nginx-helloworld:latest .
cd ../../
```
## k3d: Import image
```
k3d image import nginx-helloworld:latest -c three-node-cluster
```
## kubectl: Run docker image as pod
```
k create namespace demo
ns demo
kubectl run hello-world --image=nginx-helloworld:latest --image-pull-policy=Never --port=80
```
## kubectl: Expose pod port
```
kubectl port-forward pods/hello-world 8888:80
```
## test
```
curl http://localhost:8888
```

## kubectl: delete pod and namespace
```
k delete pod/hello-world
k delete namespace demo
```

# Kubernetes Basic - start deployment with ingress
## kubectl: create deployment
```
k create namespace demo
ns demo
kubectl create deployment hello-world --image=nginx-helloworld:latest --port=80
```
## kubectl: patch deployment, change pull policy to never
```
kubectl patch deployment hello-world --patch '{"spec": {"template": {"spec": {"containers": [{"name": "nginx-helloworld","imagePullPolicy": "Never"}]}}}}'
```
## kubectl: expose deployment as service
```
kubectl expose deployment hello-world
```
## kubectl: create ingress to service
```
kubectl create ingress hello-world --class=nginx --rule="hello-world.localdev.me/*=hello-world:80"
```
## test
```
curl https://hello-world.localdev.me -k
```
## kubectl: delete ingress, service, deployment, namespace
Not necessarily to do it one by one, just demostrate the commands
```
k delete ingress hello-world
k delete svc hello-world
k delete deploy hello-world
k delete namespace demo
```

# Kubernetes Basic - helm deploy deployment
## helm: Upgrade/install hello world using helm
```
cd helm
helm upgrade --install --atomic hello-world ./template-chart/ -f ../hello-world/helm/values.yaml  -n demo --create-namespace
cd ..
```
## test
```
curl https://hello-world.localdev.me -k
```
## clean up
```
k delete namespace demo
```