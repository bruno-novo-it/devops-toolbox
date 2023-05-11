#!/bin/bash

# https://cloud.google.com/blog/products/it-ops/filtering-and-formatting-fun-with

if [ -z "$1" ]
then
 echo -e "\nProject ID is needed!!"
 echo -e "\nExample: $0 des-bv\n"
 exit 1
fi

SNAPSHOTS=$(gcloud compute snapshots list \
    --project $1 \
    --format="table[no-heading](name)")

IFS=$'\n'

for SNAPSHOT in $SNAPSHOTS;
do
    echo "Deleting Snapshot: $SNAPSHOT"
    gcloud compute snapshots delete $SNAPSHOT \
        --project $1 --quiet
    echo "----------------------------"
done