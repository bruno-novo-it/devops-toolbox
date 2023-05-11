#!/bin/bash

if [[ -z "$1" ]]
then
 echo "Namespace Environment is needed!"
 echo "Example: des or prd"
 exit 1
fi

# Getting Cluster Namespaces
NAMESPACES=$(kubectl get ns \
                        | grep -v gke-connect,gke-system,istio-system,knative-eventing,knative-serving,kube-node-lease,kube-public,kube-system,velero \
                        | grep -i "$1-*" \
                        | awk {'print $1'})


IFS=$'\n'

for NAMESPACE in $NAMESPACES;
do
    kubectl get namespace ${NAMESPACE} -o json \
    | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
    | kubectl replace --raw /api/v1/namespaces/${NAMESPACE}/finalize -f -
done