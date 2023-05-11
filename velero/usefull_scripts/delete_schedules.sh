#!/bin/bash

if [[ -z "$1" ]]
then
 echo "Namespace Environment is needed!"
 echo "Example: des, qa, uat or prd"
 exit 1
fi

# Getting Cluster Namespaces
SCHEDULE_LIST=$(velero get schedules \
                | grep -i "$1-*" \
                | awk {'print $1'})


IFS=$'\n'

for SCHEDULE_NAME in $SCHEDULE_LIST;
do
      echo "Deleting SCHEDULE: $SCHEDULE_NAME"
      velero delete schedule $SCHEDULE_NAME --confirm
      echo "----------------------------"
done