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
      kubectl -n ${NAMESPACE} get deploy
      echo -e "\n----------------------------"
      echo -e "\nDeleting Deployment's inside namespace: $NAMESPACE"

      DEPLOYS=$(kubectl -n ${NAMESPACE} get deploy --no-headers | awk {'print $1'})

      for DEPLOY in $DEPLOYS;
      do
        kubectl -n $NAMESPACE delete deploy $DEPLOY
      done
      ##########################################################################################
      kubectl -n ${NAMESPACE} get statefulset
      echo -e "\n----------------------------"
      echo -e "\nDeleting Statefulset's inside namespace: $NAMESPACE"

      STATEFULSETS=$(kubectl -n ${NAMESPACE} get statefulset --no-headers | awk {'print $1'})

      for STATEFULSET in $STATEFULSETS;
      do
        kubectl -n $NAMESPACE delete statefulset $STATEFULSET
      done
      ##########################################################################################
      export SERVICE=svc
      kubectl -n ${NAMESPACE} get ${SERVICE}
      echo -e "\n----------------------------"
      echo -e "\nDeleting ${SERVICE}'s inside namespace: $NAMESPACE"

      SERVICES=$(kubectl -n ${NAMESPACE} get ${SERVICE} --no-headers | awk {'print $1'})

      for SERVICE_NAME in $SERVICES;
      do
        kubectl -n $NAMESPACE delete $SERVICE $SERVICE_NAME
      done
      echo -e "\n----------------------------"
      echo -e "\nFinalizando namespace: $NAMESPACE"
      sleep 5
done
