#!/bin/bash

# Source Code
# https://github.com/kubernetes/ingress-nginx

# Adding and updating Repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Setting usefull variables
NAMESPACE=nginx

# Create Nginx Namespace
kubectl create ns ${NAMESPACE} || true

# Installing Helm 3 Nginx Ingress Controller
helm upgrade --install nginx \
            --namespace ${NAMESPACE} \
            --set controller.admissionWebhooks.enabled=false \
            --set controller.enableCustomResources=true \
            --set controller.enableTLSPassthrough=true \
            --set "controller.extraArgs.enable-ssl-passthrough=" \
            -f values.yaml \
            ingress-nginx/ingress-nginx