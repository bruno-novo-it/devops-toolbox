#!/bin/bash

if [[ -z "$1" ]]
then
 echo "Namespace Name is needed!"
 echo "Example: $0 NAMESPACE_NAME"
 exit 1
fi

echo -e "\nCreating Backup for Namespace: $1"
velero backup create $1 \
      --include-namespaces $1
echo "----------------------------"

echo -e "\nList Velero Backups\n"
velero get backups