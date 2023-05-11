#!/bin/bash

# Setting variables
NAMESPACE=mysql-innodbcluster
CHART_NAME=mysql-innodbcluster

# Uninstall Helm Chart
helm -n ${NAMESPACE} delete ${CHART_NAME}

kubectl delete ns ${NAMESPACE}
