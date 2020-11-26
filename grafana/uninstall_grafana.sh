#!/usr/bin/env bash

GRAFANA_PVC_YAML=grafana_pvc.yaml
NAMESPACE=istio-system

# Uninstall Grafana Helm Chart
helm -n $NAMESPACE delete grafana

kubectl delete -f $GRAFANA_PVC_YAML