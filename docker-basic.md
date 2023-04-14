# Docker Basic - Build and Run image
## docker: Build image
```
cd hello-world/alpine
docker build --tag helloworld:v1.0 .
cd ../../
```
## docker: Run image
```
docker run --rm helloworld:v1.0
```
## docker: Remove image
```
docker rmi helloworld:v1.0
```