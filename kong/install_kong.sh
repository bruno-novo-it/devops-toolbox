#!/usr/bin/env bash

# https://github.com/bitnami/charts/tree/master/bitnami/kong --> USE THIS
# https://github.com/Kong/charts/tree/main/charts/kong

## Add Bitinami Repo
helm repo add bitnami https://charts.bitnami.com/bitnami

## Update helm repo list
helm repo update

# Create namespace kong if it not exists
kubectl create ns kong || true

# Setting some variables
CHART_NAME=kong
NAMESPACE=kong

# Postgres SubChart password
POSTGRESQL_PASSWORD=6ecHbUk1J5

# Install Kong Helm Chart
helm upgrade --install ${CHART_NAME} \
		--namespace ${NAMESPACE} \
		--set postgresql.enabled=true \
		--set postgresql.postgresqlPassword=$POSTGRESQL_PASSWORD \
		--set ingressController.enabled=true \
		--set service.type=NodePort \
		--set service.exposeAdmin=true \
		-f values.yaml \
		bitnami/kong

# Rolling out kong deployment
kubectl -n ${NAMESPACE} rollout status deployment/kong

# Applying External LoadBalancer to Serve Kong
kubectl -n ${NAMESPACE} apply -f kong_proxy_ingress.yaml

# Applying ECHO SERVER(MAKE KONG PROXY HEALTH TO GCP LB HEALTH CHECK)
kubectl -n ${NAMESPACE} apply -f echo_server.yaml

# AFTER INSTALLATION, CHANGE THE SECOND LOAD BALANCER HEALTH CHECK FROM / TO /foo
# THIS WILL MAKE KONG HEALTH