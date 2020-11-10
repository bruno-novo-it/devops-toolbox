#!/usr/bin/env bash

helm -n jenkins uninstall jenkins

kubectl delete -f jenkins_pvc.yaml

kubectl delete ns jenkins