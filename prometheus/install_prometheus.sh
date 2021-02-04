#!/bin/bash

# Add and Update Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update

# Define namespace
NAMESPACE=istio-system

# Install Prometheus Helm Chart
helm upgrade --install prometheus \
		--namespace $NAMESPACE \
		--set forceNamespace=$NAMESPACE \
		-f values.yaml \
		prometheus-community/prometheus
