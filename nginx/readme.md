docker build --tag nginx-helloworld:latest .
docker images | grep nginx-helloworld
k3d image import nginx-helloworld:latest -c three-node-cluster
