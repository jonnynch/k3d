# Environment

WSL2 on windows

It is for docker installation, for local installation, please check [this](readme-local.md)

# Install nexus3 
## set env 
```
NEXUS_DATA=~/nexus-data
```
## startup
8081: mvn pull
18443: docker pull
28443: docker push
```
mkdir $NEXUS_DATA
sudo chown -R 200 $NEXUS_DATA
docker run -d -p 8081:8081 -p 18081:18081 -p 18443:18443 -p 28443:28443 --name nexus -v $NEXUS_DATA:/nexus-data sonatype/nexus3:3.49.0
NEXUS_PASSWORD=`docker exec -it nexus cat /nexus-data/admin.password`
echo $NEXUS_PASSWORD
```
## Login and change the default password in http://localhost:8081/
```
NEXUS_PASSWORD=<New Password>
```

# Configure SSL 
## set env
```
NEXUS_DATA=~/nexus-data
```
## Configure SSL
```
cd $NEXUS_DATA/etc
sudo mkdir ssl
cd ssl
sudo keytool -genkeypair -keystore keystore.jks -storepass password -alias localdev.me \
 -keyalg RSA -keysize 2048 -validity 5000 -keypass password \
 -dname 'CN=*.localdev.me, OU=Jon, O=Jon, L=Unspecified, ST=Unspecified, C=AU' \
 -ext 'SAN=DNS:nexus.localdev.me,DNS:clm.localdev.me,DNS:repo.localdev.me,DNS:www.localdev.me,DNS:host.k3d.internal,DNS:host.docker.internal'

sudo sh -c 'keytool -exportcert -keystore keystore.jks -alias localdev.me -rfc > localdev.cert'
sudo keytool -importkeystore -srckeystore keystore.jks -destkeystore localdev.p12 -deststoretype PKCS12
sudo openssl pkcs12 -nocerts -nodes -in localdev.p12 -out localdev.key

sudo sed -i 's|# application-port=.*|application-port-ssl=8443|' $NEXUS_DATA/etc/nexus.properties
sudo sed -i 's|# nexus-args=.*|nexus-args=${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-https.xml,${jetty.etc}/jetty-requestlog.xml|' $NEXUS_DATA/etc/nexus.properties
sudo sh -c "echo 'ssl.etc=\${karaf.data}/etc/ssl' >>  $NEXUS_DATA/etc/nexus.properties"

cd /opt/nexus-3.49.0-02/etc/jetty
vi jetty-https.xml 
# <Set name="certAlias">localdev.me</Set> <--add this
# <Set name="KeyStorePath">
```

# Backup
## set env for docker
```
NEXUS_DATA=~/nexus-data
BACKUP_LOCATION=~/nexus-data/backup
```

## do backup
### Backup files
```
sudo mkdir $BACKUP_LOCATION
sudo chown -R 200 $BACKUP_LOCATION
sudo tar -C $NEXUS_DATA/blobs --exclude=proxy -cvf $BACKUP_LOCATION/blobs-`date "+%Y.%m.%d-%H.%M.%S"`.tar . 
sudo tar -C $NEXUS_DATA/keystores -cvf $BACKUP_LOCATION/keystores-node-`date "+%Y.%m.%d-%H.%M.%S"`.tar node
```

### Execute backup task
remember to create db backup task in UI if not exists

Backup location is assumed to be `/nexus-data/backup` for docker
```
TASK_ID=`curl -X 'GET' 'http://localhost:8081/service/rest/v1/tasks?type=db.backup' -H 'accept: application/json'  -u "admin:$NEXUS_PASSWORD"| jq -r '.items[0].id'`
echo $TASK_ID
curl -X 'POST' \
  "http://localhost:8081/service/rest/v1/tasks/$TASK_ID/run" \
  -H 'accept: application/json' \
  -u "admin:$NEXUS_PASSWORD"

```

# Restore 
## set env 
```
NEXUS_DATA=~/nexus-data
BACKUP_LOCATION=~/nexus-data/backup
docker stop nexus
```

## do restore
```
ls -lrt $BACKUP_LOCATION | grep -E "component-.*\.bak" | sed 's|.*component-||' 
BACKUP_DB_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "component-.*\.bak" | sed 's|.*component-||'|tail -1`

ls -lrt $BACKUP_LOCATION | grep -E "keystores-node-.*\.tar" | sed 's|.*keystores-node-||'
BACKUP_KEYSTORES_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "keystores-node-.*\.tar" | sed 's|.*keystores-node-||'|tail -1`

ls -lrt $BACKUP_LOCATION | grep -E "blobs-.*\.tar" | sed 's|.*blobs-||'
BACKUP_BLOBS_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "blobs-.*\.tar" | sed 's|.*blobs-||'|tail -1`

sudo rm -rf $NEXUS_DATA/db/component $NEXUS_DATA/db/config $NEXUS_DATA/db/security
sudo cp $BACKUP_LOCATION/component-$BACKUP_DB_SUFFIX $BACKUP_LOCATION/config-$BACKUP_DB_SUFFIX $BACKUP_LOCATION/security-$BACKUP_DB_SUFFIX $NEXUS_DATA/restore-from-backup

sudo mv $NEXUS_DATA/blobs/default $NEXUS_DATA/blobs/default-`date "+%Y.%m.%d-%H.%M.%S"`
sudo tar -xvf $BACKUP_LOCATION/blobs-$BACKUP_BLOBS_SUFFIX -C $NEXUS_DATA/blobs
sudo chown -R 200 $NEXUS_DATA/blobs

sudo mv $NEXUS_DATA/keystores/node $NEXUS_DATA/keystores/node-`date "+%Y.%m.%d-%H.%M.%S"`
sudo tar -xvf $BACKUP_LOCATION/keystores-node-$BACKUP_KEYSTORES_SUFFIX -C $NEXUS_DATA/keystores
sudo chown -R 200 $NEXUS_DATA/keystores
```
Manual delete of the folders of all proxy repository from UI. because they are not in backup

## Verify
### check log
```
docker start nexus
docker logs -f nexus
```
### login and check the blob storage

### Healthcheck for different proxy repository (docker.io, docker.elastic.co, maven central)
```
docker pull localdev.me:18443/library/alpine:latest
docker pull localdev.me:18443/elasticsearch/elasticsearch:8.7.0
mvn dependency:get -Dartifact=org.springframework.boot:spring-boot:3.0.4:jar -DremoteRepositories=http://localhost:8081/repository/maven-public/ -Dtransitive=false
```

### Verify ok
```
sudo rm $NEXUS_DATA/restore-from-backup/*
```