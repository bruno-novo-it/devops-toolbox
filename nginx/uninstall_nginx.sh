#!/bin/bash

NAMESPACE=nginx

helm -n ${NAMESPACE} delete nginx

kubectl delete ns ${NAMESPACE}