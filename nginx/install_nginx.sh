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
            -f values.yaml \
            ingress-nginx/ingress-nginx

## Possible error's
## https://stackoverflow.com/questions/61616203/nginx-ingress-controller-failed-calling-webhook
## Error from server (InternalError): error when creating "yaml/xxx/xxx-ingress.yaml": Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": Post https://ingress-nginx-controller-admission.ingress-nginx.svc:443/extensions/v1beta1/ingresses?timeout=30s: Temporary Redirect
