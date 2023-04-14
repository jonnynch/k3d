# Environment
```
WSL2 on windows
```

# Install nexus3 
```
NEXUS_DATA=/opt/sonatype-work/nexus3

wget https://download.sonatype.com/nexus/3/nexus-3.49.0-02-unix.tar.gz
sudo tar xvzf nexus-3.49.0-02-unix.tar.gz -C /opt
sudo chown -R $USER sonatype-work nexus-3.49.0-02
sudo apt-get install openjdk-8-jre
cd /usr/lib/jvm
sudo ln -s java-8-openjdk-amd64 java-8

export PATH=$PATH:/opt/nexus-3.49.0-02/bin/
export INSTALL4J_JAVA_HOME=/usr/lib/jvm/java-8
nexus start
tail -f $NEXUS_DATA/log/nexus.log
nexus stop

```

# Configure SSL 
```
NEXUS_DATA=/opt/sonatype-work/nexus3

cd $NEXUS_DATA/etc
mkdir ssl
cd ssl
keytool -genkeypair -keystore keystore.jks -storepass password -alias localdev.me \
 -keyalg RSA -keysize 2048 -validity 5000 -keypass password \
 -dname 'CN=*.localdev.me, OU=Jon, O=Jon, L=Unspecified, ST=Unspecified, C=AU' \
 -ext 'SAN=DNS:nexus.localdev.me,DNS:clm.localdev.me,DNS:repo.localdev.me,DNS:www.localdev.me,DNS:host.k3d.internal'

keytool -exportcert -keystore keystore.jks -alias localdev.me -rfc > localdev.cert
keytool -importkeystore -srckeystore keystore.jks -destkeystore localdev.p12 -deststoretype PKCS12
openssl pkcs12 -nocerts -nodes -in localdev.p12 -out localdev.key

sed -i 's|# application-port=.*|application-port-ssl=8443|' $NEXUS_DATA/etc/nexus.properties
sed -i 's|# nexus-args=.*|nexus-args=${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-https.xml,${jetty.etc}/jetty-requestlog.xml|' $NEXUS_DATA/etc/nexus.properties
echo 'ssl.etc=\${karaf.data}/etc/ssl' >>  $NEXUS_DATA/etc/nexus.properties

cd /opt/nexus-3.49.0-02/etc/jetty
vi jetty-https.xml 
# <Set name="certAlias">localdev.me</Set> <--add this
# <Set name="KeyStorePath">
```

# Backup
## set env
```
NEXUS_DATA=/opt/sonatype-work/nexus3
BACKUP_LOCATION=/mnt/c/backup/nexus
```

## do backup
### Backup files
```
mkdir $BACKUP_LOCATION
tar -C $NEXUS_DATA/blobs -cvf $BACKUP_LOCATION/blobs-`date "+%Y.%m.%d-%H.%M.%S"`.tar .
tar -C $NEXUS_DATA/keystores -cvf $BACKUP_LOCATION/keystores-node-`date "+%Y.%m.%d-%H.%M.%S"`.tar node
```

### Execute backup task
remember to create db backup task in UI

Backup location is assumed to be `/mnt/c/backup/nexus` 
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
NEXUS_DATA=/opt/sonatype-work/nexus3
BACKUP_LOCATION=/mnt/c/backup/nexus
export PATH=$PATH:/opt/nexus-3.49.0-02/bin/
nexus stop
```

## do restore
```
ls -lrt $BACKUP_LOCATION | grep -E "component-.*\.bak" | sed 's|.*component-||' 
BACKUP_DB_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "component-.*\.bak" | sed 's|.*component-||'|tail -1`

ls -lrt $BACKUP_LOCATION | grep -E "keystores-node-.*\.tar" | sed 's|.*keystores-node-||'
BACKUP_KEYSTORES_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "keystores-node-.*\.tar" | sed 's|.*keystores-node-||'|tail -1`

ls -lrt $BACKUP_LOCATION | grep -E "blobs-.*\.tar" | sed 's|.*blobs-||'
BACKUP_BLOBS_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "blobs-.*\.tar" | sed 's|.*blobs-||'|tail -1`

rm -rf $NEXUS_DATA/db/component $NEXUS_DATA/db/config $NEXUS_DATA/db/security
cp $BACKUP_LOCATION/component-$BACKUP_DB_SUFFIX $BACKUP_LOCATION/config-$BACKUP_DB_SUFFIX $BACKUP_LOCATION/security-$BACKUP_DB_SUFFIX $NEXUS_DATA/restore-from-backup

mv $NEXUS_DATA/blobs/default $NEXUS_DATA/blobs/default-`date "+%Y.%m.%d-%H.%M.%S"`
tar -xvf $BACKUP_LOCATION/blobs-$BACKUP_BLOBS_SUFFIX -C $NEXUS_DATA/blobs

mv $NEXUS_DATA/keystores/node $NEXUS_DATA/keystores/node-`date "+%Y.%m.%d-%H.%M.%S"`
tar -xvf $BACKUP_LOCATION/keystores-node-$BACKUP_KEYSTORES_SUFFIX -C $NEXUS_DATA/keystores

```

## Verify
### check log
```
tail -f $NEXUS_DATA/log/nexus.log
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