#!/bin/bash

if [[ -z "$1" || -z "$2" ]]
then
 echo -e "\nProject ID Origin, Project ID Destiny are needed!!"
 echo -e "\nExample: $0 qa--bv bv-atacado-qa\n"
 exit 1
fi

export PROJECT_ID_ORIGIN=$1

export PROJECT_ID_DESTINY=$2

export REGION=southamerica-east1

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