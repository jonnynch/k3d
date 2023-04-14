# Install SonarQube
```
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create namespace sonarqube
helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube

kubectl create ingress sonarqube --class=nginx --rule="sonarqube.localdev.me/*=sonarqube-sonarqube:9000" -n sonarqube
```

# Generate token
1. Login to https://sonarqube.localdev.me by admin/admin
2. Change password
3. Generate token from My Account > Security > Generate Tokens 
4. Add it in jenkins credential as type secret text using id `sonar-credential`
5. Configure Sonarqube installation in Manage Jenkins > Configure System as name `sonarqube`, url `http://sonarqube-sonarqube.sonarqube.svc:9000`