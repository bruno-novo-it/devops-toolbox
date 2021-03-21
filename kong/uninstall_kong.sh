#!/bin/bash

# Setting some variables
CHART_NAME=kong
NAMESPACE=kong

# Uninstall Kong Helm Chart
helm -n ${NAMESPACE} delete ${CHART_NAME}

# Deleting External LoadBalancer
kubectl -n ${NAMESPACE} delete -f kong_proxy_ingress.yaml

# Deleting ECHO SERVER
kubectl -n ${NAMESPACE} delete -f echo_server.yaml

# Deleting namespace
kubectl delete ns ${NAMESPACE}