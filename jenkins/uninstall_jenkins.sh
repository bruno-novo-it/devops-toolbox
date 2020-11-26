#!/usr/bin/env bash

NAMESPACE=jenkins
PVC_YAML=jenkins_pvc.yaml

helm -n $NAMESPACE delete jenkins

kubectl delete -f $PVC_YAML

kubectl delete ns $NAMESPACE