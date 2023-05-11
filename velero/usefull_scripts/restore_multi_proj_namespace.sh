#!/bin/bash

if [[ -z "$1" ]]
then
 echo -e "\nProject ID Origin, Project ID Destiny are needed!!"
 echo -e "\nExample: $0 NAMESPACE_NAME\n"
 exit 1
fi

export NAMESPACE_NAME=$1

export REGION=southamerica-east1

echo "Restoring Backup for namespace: $NAMESPACE_NAME"
velero restore create --from-backup $NAMESPACE_NAME
echo "----------------------------"