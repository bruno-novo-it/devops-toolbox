#!/bin/bash

export NAMESPACE=velero
export DEPLOYMENT_NAME=velero

# Scale Velero Deployment
kubectl -n ${NAMESPACE} scale deploy ${DEPLOYMENT_NAME} --replicas=1