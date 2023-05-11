#!/bin/bash

if [[ -z "$1" ]]
then
 echo "Namespace Environment is needed!"
 echo "Example: des, qa, uat or prd"
 exit 1
fi

# Getting Cluster Namespaces
NAMESPACES=$(kubectl get ns \
                        | grep -v gke-connect,gke-system,istio-system,knative-eventing,knative-serving,kube-node-lease,kube-public,kube-system,velero \
                        | grep -i "$1-*" \
                        | awk {'print $1'})

IFS=$'\n'

for NAMESPACE in $NAMESPACES;
do
      echo "Creating Backup for namespace: $NAMESPACE"
      velero backup create $NAMESPACE \
      --include-namespaces $NAMESPACE
      echo "----------------------------"
done

echo -e "\nList Backups\n"
velero get backups

echo -e "\List total Backups\n"
velero get backups | wc -l