#!/usr/bin/env bash

# https://github.com/bitnami/charts/tree/master/bitnami/kong --> USE THIS
# https://github.com/Kong/charts/tree/main/charts/kong

## Add Bitinami Repo
helm repo add bitnami https://charts.bitnami.com/bitnami

## Update helm repo list
helm repo update

# Create namespace kong if it not exists
kubectl create ns kong || true

# Setting some variables
HELM_CHART_NAME=kong
NAMESPACE=kong

# Install Kong Helm Chart
helm upgrade --install $HELM_CHART_NAME \
		--namespace $NAMESPACE \
		--set postgresql.enabled=false \
		-f values.yaml \
		bitnami/kong