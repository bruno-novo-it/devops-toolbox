#!/bin/bash

# https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-innodbcluster-simple-helm.html

# Setting variables
CHART_NAME=mysql-innodbcluster
NAMESPACE=mysql-innodbcluster

# Create namespace if it not exists
kubectl create ns ${NAMESPACE} || true

# Install Helm Chart
helm upgrade --install ${CHART_NAME} \
    --namespace ${NAMESPACE} \
    --set credentials.root.user='root' \
    --set credentials.root.password='root' \
    --set credentials.root.host='%' \
    --set serverInstances=1 \
    --set routerInstances=1 \
    --set tls.useSelfSigned=true \
    mysql-operator/mysql-innodbcluster
