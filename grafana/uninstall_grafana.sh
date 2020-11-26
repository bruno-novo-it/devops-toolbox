#!/usr/bin/env bash

NAMESPACE=istio-system
PVC_YAML=grafana_pvc.yaml

# Uninstall Grafana Helm Chart
helm -n $NAMESPACE delete grafana

kubectl delete -f $PVC_YAML