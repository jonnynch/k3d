# prometheus install
```
NAMESPACE=monitoring
k create namespace $NAMESPACE
ns $NAMESPACE
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus -n $NAMESPACE
# export POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
# kubectl --namespace $NAMESPACE port-forward $POD_NAME 9090
kubectl create ingress prometheus-server --class=nginx --rule="prometheus.localdev.me/*=prometheus-server:9090" -n $NAMESPACE
```

# grafana install
```
NAMESPACE=monitoring
kubectl apply -f monitoring/grafana/grafana.yaml -n $NAMESPACE
# kubectl port-forward service/grafana 3000:3000 -n $NAMESPACE
kubectl create ingress grafana --class=nginx --rule="grafana.localdev.me/*=grafana:3000" -n $NAMESPACE
# login using admin/admin
# add prometheus datasource using http://prometheus-server/
# add panel by using id found in https://grafana.com/grafana/dashboards/?search=kubernetes
```

# zipkin install
```
NAMESPACE=monitoring
helm upgrade --install --atomic zipkin ./helm/template-chart/ -f monitoring/zipkin/helm/values.yaml -n $NAMESPACE

```