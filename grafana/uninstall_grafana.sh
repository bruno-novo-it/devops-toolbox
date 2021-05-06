#!/usr/bin/env bash

# Setting variables
NAMESPACE=istio-system
CHART_NAME=grafana
PVC_YAML=grafana_pvc.yaml

# Uninstall Grafana Helm Chart
helm -n ${NAMESPACE} delete ${CHART_NAME}

kubectl delete -f ${PVC_YAML}