#!/bin/bash

if [[ -z "$1" ]]
then
 echo "Namespace Name is needed!"
 echo "Example: $0 NAMESPACE_NAME"
 exit 1
fi

echo -e "\nCreating Schedule to Backup Namespace: $1"
velero create schedule $1 \
      --schedule="@every 24h" \
      --include-namespaces $1 \
      --ttl 168h0m0s

# Obs: This will create a Schedule to Backup the namespace
#      every day and will delete the ones that pass 7 days

echo -e "\nList Kubernetes System Schedules\n"
velero get schedules

echo -e "\nList Kubernetes System Backups\n"
velero get backups