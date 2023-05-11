#!/bin/bash

# Setting variables
NAMESPACE=monitoring
CHART_NAME=grafana
PVC_YAML_FILE=grafana_pvc.yaml

# Uninstall Grafana Helm Chart
helm -n ${NAMESPACE} delete ${CHART_NAME}

kubectl delete -f ${PVC_YAML_FILE}
