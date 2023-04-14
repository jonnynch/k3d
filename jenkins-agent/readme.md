# Setup jenkins-agent on kubernetes
You will need the following for jenkins kubernetes integration
1. remember to update server url from 0.0.0.0 to host.docker.internal if jenkins in docker
2. better to update the port to 6443 for static port binding
3. create maven-conf secret from correct settings.xml
```
# Create kubeconfig.k3d and then add into jenkins credential as secret file
# and configured in kubernetes plugin
k3d kubeconfig get three-node-cluster > kubeconfig.k3d
sed -i 's/0.0.0.0:.*/host.docker.internal:6443/g' kubeconfig.k3d
```

Some kubernetes plugin parameters

`k3d-kubeconfig` is the credential that created above
```
      <serverUrl>https://host.docker.internal:6443</serverUrl>
      <useJenkinsProxy>false</useJenkinsProxy>
      <skipTlsVerify>true</skipTlsVerify>
      <namespace>jenkins</namespace>
      <jnlpregistry>host.k3d.internal:18443</jnlpregistry>
      <jenkinsUrl>http://host.k3d.internal:8080</jenkinsUrl>
      <jenkinsTunnel>host.k3d.internal:50000</jenkinsTunnel>
      <credentialsId>k3d-kubeconfig</credentialsId>
```

Create jenkins namespace for agent to execute
```
k create namespace jenkins
ns jenkins
NEXUS_PASSWORD=`docker exec -it nexus cat /nexus-data/admin.password`
cat jenkins-agent/maven/settings-placeholder.xml | sed "s/@@nexusPassword@@/$NEXUS_PASSWORD/g" > jenkins-agent/maven/settings.xml
k create secret generic maven-conf --from-file=jenkins-agent/maven/settings.xml
k create cm docker-conf --from-file=$NEXUS_DATA/etc/ssl/localdev.cert
rm jenkins-agent/maven/settings.xml

kubectl create clusterrolebinding jenkins-edit-binding --clusterrole=edit --serviceaccount=jenkins:default --namespace=jenkins
```

# install jenkins-agent on machine
```
sudo mkdir /home/jenkins-agent
sudo chown -R jonng:jonng /home/jenkins-agent
cd /home/jenkins-agent
echo 7f6c7351a90f5098c27af0fc892c25ec05500a2c4f96b71a12bf08ec1a15ddaf > secret-file
curl -sO http://localhost:8080/jnlpJars/agent.jar
java -jar agent.jar -jnlpUrl http://localhost:8080/manage/computer/jenkins%2Dagent/jenkins-agent.jnlp -secret @secret-file -workDir "/home/jenkins-agent"
```