#!/bin/bash

# Setting variables
NAMESPACE=mysql-operator
CHART_NAME=mysql-operator

# Uninstall Helm Chart
helm -n ${NAMESPACE} delete ${CHART_NAME}

kubectl delete ns ${NAMESPACE}
