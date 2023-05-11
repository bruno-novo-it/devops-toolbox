#!/bin/bash

# Get Velero Backups
VELERO_BACKUPS=$(velero backup get \
                  | tail -n +2 \
                  | awk '{ print $1}')

IFS=$'\n'

for BACKUP in $VELERO_BACKUPS;
do
      echo "Restoring Backup for namespace: $BACKUP"
      velero restore create --from-backup $BACKUP
      echo "----------------------------"
done