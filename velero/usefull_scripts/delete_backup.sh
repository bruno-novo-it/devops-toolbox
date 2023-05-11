#!/bin/bash

if [[ -z "$1" ]]
then
 echo "Namespace Environment is needed!"
 echo "Example: des, qa, uat or prd"
 exit 1
fi

# Getting Cluster Namespaces
BACKUP_LIST=$(velero get backups \
                | grep -i "$1-*" \
                | awk {'print $1'})


IFS=$'\n'

for BACKUP_NAME in $BACKUP_LIST;
do
      echo "Deleting Backup: $BACKUP_NAME"
      velero delete backup $BACKUP_NAME --confirm
      kubectl delete backups.velero.io -n velero $BACKUP_NAME
      echo "----------------------------"
done