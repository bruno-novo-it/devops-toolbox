#!/bin/bash

# https://github.com/grafana/helm-charts

# Setting variables
NAMESPACE=monitoring
CHART_NAME=grafana
PVC_YAML_FILE=grafana_pvc.yaml
PVC_CLAIM_NAME=grafana-pvc

## Add Grafana Repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create namespace if it not exists
kubectl create ns ${NAMESPACE} || true

# Create Grafana PVC
kubectl -n ${NAMESPACE} apply -f ${PVC_YAML_FILE}

# Install Grafana Helm Chart
helm upgrade --install ${CHART_NAME} \
		--namespace ${NAMESPACE} \
		--set namespaceOverride=${NAMESPACE} \
		--set persistence.existingClaim=${PVC_CLAIM_NAME} \
		--set persistence.enabled=true \
		--set persistence.type=pvc \
		-f values.yaml \
		grafana/grafana


kubectl apply -f grafana_ingress.yaml

echo -e "\nGrafana URL: `kubectl -n ${NAMESPACE} get ingress grafana-ingress -o jsonpath="{.spec.rules[0].host}"`"

echo -e "\nGrafana User: `kubectl -n ${NAMESPACE} get secret grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo`"

echo -e "\nGrafana Password: `kubectl -n ${NAMESPACE} get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`"

# How to get secret
# kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
