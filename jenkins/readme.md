# Environment

WSL2 on windows

It is for docker installation, for local installation, please check [this](readme-local.md)

# install jenkins
## set env 
```
JENKINS_DATA=~/jenkins-data
BACKUP_LOCATION=~/jenkins-data-backup
```

## startup
```
mkdir $JENKINS_DATA
docker pull jenkins/jenkins:2.387.2-lts-jdk11
docker run -d -p 8080:8080 -p 50000:50000 --restart=on-failure \
-v $JENKINS_DATA:/var/jenkins_home \
-v $BACKUP_LOCATION:/var/backups \
--name jenkins jenkins/jenkins:2.387.2-lts-jdk11 
cat $JENKINS_DATA/secrets/initialAdminPassword 
```

## Start
```
docker rm jenkins -f 
docker start jenkins
```

## Stop
```
docker stop jenkins
```

# Backup
## set env
```
JENKINS_DATA=~/jenkins-data
BACKUP_LOCATION=~/jenkins-data-backup
```

## do backup
### Backup files
```
mkdir $BACKUP_LOCATION
tar -C $JENKINS_DATA -cvf $BACKUP_LOCATION/jenkins-`date "+%Y.%m.%d-%H.%M.%S"`.tar .
```

# Restore 
## set env 
```
JENKINS_DATA=~/jenkins-data
BACKUP_LOCATION=~/jenkins-data-backup
docker stop jenkins
```

## do restore
```
ls -lrt $BACKUP_LOCATION | grep -E "jenkins-.*\.tar" | sed 's|.*jenkins-||' 
BACKUP_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "jenkins-.*\.tar" | sed 's|.*jenkins-||'|tail -1`

rm -rf $JENKINS_DATA
mkdir $JENKINS_DATA
tar -xvf $BACKUP_LOCATION/jenkins-$BACKUP_SUFFIX -C $JENKINS_DATA
```


# encrypt password for manual password update from $JENKINS_DATA/users/XXX/config.xml
```
pip install bcrypt
python3
>>> import bcrypt
>>> bcrypt.hashpw("yourpassword", bcrypt.gensalt(rounds=10, prefix=b"2a"))
'YOUR_HASH'
```

# create namespace
```
k create namespace jenkins
```