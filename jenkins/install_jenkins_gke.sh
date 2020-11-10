#!/usr/bin/env bash

# https://github.com/jenkinsci/helm-charts/tree/main/charts/jenkins

# Add Jenkins Helm Chart
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Create Jenkins Namespace
kubectl create ns jenkins || true

# Create Jenkins PVC
kubectl apply -f jenkins_pvc.yaml

# Wait for PVC Creating
sleep 10

# Install Jenkins Helm Chart
helm upgrade --install jenkins \
        --namespace jenkins \
        -f jenkins_values.yaml \
        --set persistence.existingClaim=jenkins-pvc \
        jenkins/jenkins

# Rolling out Jenkins deployment
kubectl -n jenkins rollout status deployment/jenkins