# Install ELK
## Install ECK Operator
```
helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace
```
## Install ElasticSearch 1 mode
```
ns elastic-system
kubectl apply -f elk/elastic-search/elastic-search.yaml

PASSWORD=$(kubectl get secret monitoring-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
kubectl port-forward service/monitoring-es-http 9200
curl -u "elastic:$PASSWORD" -k "https://localhost:9200"
kubectl delete elasticsearch monitoring
```
## Install ElasticSearch 3 nodes
```
ns elastic-system
kubectl apply -f elk/elastic-search/elastic-search-3-nodes.yaml

# wait for healthy
kubectl get es

PASSWORD=$(kubectl get secret monitoring-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
kubectl port-forward service/monitoring-es-http 9200 &
curl -u "elastic:$PASSWORD" "https://localhost:9200" -k 
ps -ef|grep "kubectl port-forward service/monitoring-es-http 9200"|grep -v "grep"
kill -9 `ps -ef|grep "kubectl port-forward service/monitoring-es-http 9200"|grep -v "grep" | awk '{print $2}'`
```
## Install Kibana
```
kubectl apply -f elk/kibana/kibana.yaml

kubectl get secret monitoring-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo

# wait for healthy
kubectl get kb

kubectl create ingress monitoring-kb-http --class=nginx --rule="kibana.localdev.me/*=monitoring-kb-http:5601" --annotation="nginx.ingress.kubernetes.io/backend-protocol=HTTPS"
```
## Access kibana
https://kibana.localdev.me/

User: `elastic`

Password: `<from previous command>`

## Install FileBeat
```
k apply -f elk/filebeat/filebeat.yaml
```