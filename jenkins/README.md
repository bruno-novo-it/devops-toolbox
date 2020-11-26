## How to

```sh
JENKINS_POD=`kubectl get pods | grep "jenkins*" | awk {'print $1'}`
kubectl exec $JENKINS_POD -- cat /var/jenkins_home/secrets/initialAdminPassword
```

```sh
NOTES:
1. Get your 'admin' user password by running:
  printf $(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace jenkins -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=jenkins" -o jsonpath="{.items[0].metadata.name}")
  echo http://127.0.0.1:8080
  kubectl --namespace jenkins port-forward $POD_NAME 8080:8080

3. Login with the password from step 1 and the username: admin

4. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http:///configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos
```
