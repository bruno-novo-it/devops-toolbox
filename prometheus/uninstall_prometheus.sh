#!/bin/bash

# Define namespace
NAMESPACE=istio-system
CHART_NAME=prometheus

# Uninstall Prometheus Helm Chart
helm -n $NAMESPACE delete ${CHART_NAME}
