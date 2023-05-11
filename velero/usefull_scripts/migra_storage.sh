SNAPSHOT_INFO=`velero backup describe $BACKUP --details | grep "Snapshot ID:" | awk '{print $3}'`

    if [[ -z $SNAPSHOT_INFO ]]
    then
    echo -e "\nThere is no Snapshot is this Backup...\n"
    else
    echo -e "\nThere is one or more Snapshot's in this Backup!!\n"
    for SNAPSHOT in $SNAPSHOT_INFO;
    do
        echo -e "\nCreating Snapshot: $SNAPSHOT from the Project: $PROJECT_ID_ORIGIN Source Disk in Project: $PROJECT_ID_DESTINY"

        SOURCE_DISK=`gcloud compute snapshots describe $SNAPSHOT --project $PROJECT_ID_ORIGIN --format json | jq .sourceDisk -r | sed 's/^.*\v1\///'`

        gcloud beta compute snapshots create $SNAPSHOT \
            --source-disk $SOURCE_DISK \
            --storage-location $REGION \
            --project ${PROJECT_ID_DESTINY}
        echo "----------------------------"
    done
    fi