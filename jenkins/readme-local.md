# install jenkins on machine
```
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install fontconfig openjdk-11-jre
sudo apt-get install jenkins
```
## startup
```
sudo service jenkins start
```
## Stop
```
sudo service jenkins stop
```

# Backup
## set env
```
JENKINS_DATA=/var/lib/jenkins
BACKUP_LOCATION=~/jenkins-data-backup
```

## do backup
### Backup files
```
mkdir $BACKUP_LOCATION
sudo tar -C $JENKINS_DATA -cvf $BACKUP_LOCATION/jenkins-`date "+%Y.%m.%d-%H.%M.%S"`.tar .
```

# Restore 
## set env 
```
JENKINS_DATA=~/.jenkins
BACKUP_LOCATION=~/jenkins-data-backup
```

## do restore
```
ls -lrt $BACKUP_LOCATION | grep -E "jenkins-.*\.tar" | sed 's|.*jenkins-||' 
BACKUP_SUFFIX=`ls -lrt $BACKUP_LOCATION | grep -E "jenkins-.*\.tar" | sed 's|.*jenkins-||'|tail -1`

rm -rf $JENKINS_DATA/*
sudo tar -xvf $BACKUP_LOCATION/jenkins-$BACKUP_SUFFIX -C $JENKINS_DATA
```