# Installation or upgrade k3d
```
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

# Install Nexus
Please check [Nexus](./nexus/readme.md).

# Create single node cluster
```
k3d cluster create k3d-cluster
k3d cluster delete k3d-cluster
```

# Create 3 nodes cluster (1 master + 3 agent)
```
k3d cluster create three-node-cluster --agents 3
k3d cluster delete three-node-cluster
```

# Create 3 nodes cluster with registries.yaml
```
sudo mkdir -p $HOME/k3d-data/server{0..2}
sudo mkdir -p $HOME/k3d-data/agent{0..2}
sudo mkdir -p $HOME/k3d-data/shared
sudo chown -R 200 $HOME/k3d-data
sudo chmod -R 777 $HOME/k3d-data

k3d cluster create three-node-cluster --servers 3 --agents 3 \
 --volume "$HOME/k3d-data/agent0:/var/lib/rancher/k3s/storage@agent:0" \
 --volume "$HOME/k3d-data/agent1:/var/lib/rancher/k3s/storage@agent:1" \
 --volume "$HOME/k3d-data/agent2:/var/lib/rancher/k3s/storage@agent:2" \
 --volume "$HOME/k3d-data/server0:/var/lib/rancher/k3s/storage@server:0" \
 --volume "$HOME/k3d-data/server1:/var/lib/rancher/k3s/storage@server:1" \
 --volume "$HOME/k3d-data/server2:/var/lib/rancher/k3s/storage@server:2" \
 --volume "$HOME/k3d-data/shared:/mnt/shared@all" \
 --k3s-node-label "node-type=worker@agent:*" \
 --k3s-node-label "node-type=master@server:*" \
 -p 443:443@loadbalancer \
 -p 6443:6443@loadbalancer \
 --k3s-arg "--disable=traefik@server:*" \
 --registry-config "${PWD}/registry/registries.yaml"

echo 'alias k="kubectl"' >> ~/.bash_profile
echo 'alias ns="kubectl config set-context --current --namespace"' >> ~/.bash_profile
source ~/.bash_profile

k create namespace demo
ns demo
kubectl run alpine -it --rm --image localdev.me/alpine:3.15.0 -- /bin/sh
k delete namespace demo

```
# Docker Basic - optional
Please check [Docker Basic](./docker-basic.md).

# Kubernetes Basic - optional
Please check [Kubernetes Basic](./k8s-basic.md).

# Install helm on local machine
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

# Helm: install nginx ingress controller
```
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace
```

# Install Kubernetes Dashboard 
Please check [Kubernetes Dashboard ](./kubernetes-dashboard/readme.md).

# Install ELK
Please check [ELK](./elk/readme.md).

# Install Jenkins
Please check [Jenkins](./jenkins/readme.md).

# setup jenkins-agent on kubernetes/local machine
Please check [Jenkins Agent](./jenkins-agent/readme.md).

# install  monitoring  (prometheus, grafana, zipkin)
Please check [Monitoring](./monitoring/readme.md).

# terraform
Please check [Terraform](./terraform/readme.md).

# PostgreSQL for different namespaces
Please check [PostgreSQL](./postgresql/readme.md).
