#!/bin/bash

## https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus

# ## Verify if NodePool was passed
# if [ -z "$1" ]
# then
#  echo "NodePool is needed!"
#  exit 1
# fi

# Adding Helm Repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update

# Defining namespace
NAMESPACE=istio-system
NODEPOOL=$1

# Create namespace istio-system if it not exists
kubectl create ns ${NAMESPACE} || true

# Install Prometheus Helm Chart
helm upgrade --install prometheus \
		--namespace $NAMESPACE \
		--set forceNamespace=$NAMESPACE \
		--set server.nodeSelector."cloud\.google\.com/gke-nodepool"=$NODEPOOL \
		--set kube-state-metrics.nodeSelector."cloud\.google\.com/gke-nodepool"=$NODEPOOL \
		-f values.yaml \
		prometheus-community/prometheus

# Applying scraping configs
kubectl -n ${NAMESPACE} apply -f prometheus-configmap.yaml