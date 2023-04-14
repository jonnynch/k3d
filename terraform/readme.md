# terraform install on local machine
```
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform
```

## Create docker config.json to nexus
```
mkdir -p terraform/.docker
docker --config terraform/.docker login localdev.me:18443

```

## Create ingress certificate per namespace
```
NAMESPACE=demo
mkdir -p terraform/.tls/$NAMESPACE
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout terraform/.tls/$NAMESPACE/tls.key -out terraform/.tls/$NAMESPACE/tls.crt -subj "/CN=*.$NAMESPACE.localdev.me/O=local" -addext "subjectAltName = DNS:*.$NAMESPACE.localdev.me"
```

## Create namespace using terraform
```
cd terraform/
#formatting
terraform fmt

terraform init
terraform workspace show
NAMESPACE=demo
terraform workspace new $NAMESPACE
terraform plan -var-file="tfvars/$NAMESPACE.tfvars" 
#speed up
terraform plan -var-file="tfvars/$NAMESPACE.tfvars" -refresh=false

terraform apply -var-file="tfvars/$NAMESPACE.tfvars"  -auto-approve
```
## Destroy namespace using terraform
```
terraform destroy -var-file="tfvars/$NAMESPACE.tfvars" 
```