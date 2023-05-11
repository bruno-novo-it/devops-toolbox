#!/usr/bin/env bash

# https://hub.helm.sh/charts/vmware-tanzu/velero
# https://github.com/vmware-tanzu/helm-charts

NAMESPACE=velero

# Uninstall Velero Helm Chart
helm -n ${NAMESPACE} del velero

kubectl delete ns velero