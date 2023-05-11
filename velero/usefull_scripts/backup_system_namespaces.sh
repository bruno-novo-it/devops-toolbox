#!/bin/bash


echo -e "\nCreating System Schedule Backup\n"
velero create schedule daily-system-namespaces-backup \
      --schedule="@every 24h" \
      --include-namespaces gke-connect,gke-system,istio-system,knative-eventing,knative-serving,kube-node-lease,kube-public,kube-system \
      --ttl 168h0m0s

echo -e "\nList System Schedules\n"
velero get schedules

echo -e "\nList System Backups\n"
velero get backups