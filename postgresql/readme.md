# PostgreSQL


## installation
```
# add repo for postgres-operator
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator

# install the postgres-operator
helm install postgres-operator postgres-operator-charts/postgres-operator -n postgres-operator --create-namespace

# add repo for postgres-operator-ui
helm repo add postgres-operator-ui-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui

# install the postgres-operator-ui
helm install postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui -n postgres-operator --create-namespace
```

## Create postgreSQL cluster
```
# create a Postgres cluster
NAMESPACE=demo
kubectl create -f postgresql/manifests/minimal-postgres-manifest.yaml -n $NAMESPACE
k exec -it appdb-0 -- psql -Upostgres appdb
SELECT * FROM pg_catalog.pg_tables;
exit
```
