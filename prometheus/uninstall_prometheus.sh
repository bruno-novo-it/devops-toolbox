#!/bin/bash

# Define namespace
NAMESPACE=istio-system

# Uninstall Prometheus Helm Chart
helm -n $NAMESPACE delete prometheus
