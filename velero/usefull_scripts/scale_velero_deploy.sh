#!/bin/bash

if [[ -z "$1" ]]
then
 echo "Number of replicas is needed!"
 echo "Example: $0 5"
 exit 1
fi

export NAMESPACE=velero
export DEPLOYMENT_NAME=velero

# Scale Velero Deployment
kubectl -n ${NAMESPACE} scale deploy ${DEPLOYMENT_NAME} --replicas=$1