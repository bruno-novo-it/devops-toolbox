#!/bin/bash

NAMESPACE=nginx

helm -n ${NAMESPACE} delete nginx-internal

kubectl delete ns ${NAMESPACE}