#!/usr/bin/env bash

# https://github.com/grafana/helm-charts

# Setting variables
NAMESPACE=istio-system
CHART_NAME=grafana
GRAFANA_PVC_YAML=grafana_pvc.yaml
GRAFANA_PVC_CLAIM_NAME=grafana-pvc
IMAGE_REPOSITORY=grafana/grafana
IMAGE_TAG=7.5.5
SERVICE_PORT=3000

## Add Grafana Repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create namespace istio-system if it not exists
kubectl create ns ${NAMESPACE} || true

# Create Grafana PVC
kubectl -n $NAMESPACE apply -f $GRAFANA_PVC_YAML

# Install Grafana Helm Chart
helm upgrade --install ${CHART_NAME} \
		--namespace $NAMESPACE \
		--set namespaceOverride=$NAMESPACE \
		--set persistence.existingClaim=$GRAFANA_PVC_CLAIM_NAME \
		--set persistence.enabled=true \
		--set persistence.type=pvc \
		--set image.repository=$IMAGE_REPOSITORY \
		--set image.tag=$IMAGE_TAG \
		--set service.port=$SERVICE_PORT \
		-f values.yaml \
		grafana/grafana