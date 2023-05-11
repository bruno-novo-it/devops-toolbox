
### https://github.com/helm/charts/blob/master/stable/velero/values.yaml

### https://hub.helm.sh/charts/vmware-tanzu/velero

### https://medium.com/@ct.ics2009/install-velero-with-helm-in-gcp-15b7a0186ae

### https://blah.cloud/automation/using-velero-for-k8s-backup-and-restore-of-csi-volumes/




velero backup create BACKUP_NAME --include-namespaces NAMESPACE_NAME

velero backup describe BACKUP_NAME --details OR velero backup logs BACKUP_NAME


velero get backups

velero backup logs <bakup_name>

velero restore create --from-backup BACKUP_NAME --include-namespaces NAMESPACE_NAME

velero restore logs BACKUP_NAME

velero restore describe BACKUP_NAME-LOG_NUMBER --details



## Schedule Backup to be taken every hour and to be held for 24 hours each.
```
    velero create schedule hourly --schedule="@every 1h" --ttl 24h0m0s
```

## Let’s create another that runs daily and retains the backups for 7 days:
```
    velero create schedule daily --schedule="@every 24h" --ttl 168h0m0s
```
## Schedule for One namespace for every 30 minutes and retain for 2 days
```
    velero create schedule backup-tutorial --schedule="*/30 * * * *" --include-namespaces backup-tutorial --ttl 48h0m0s
```

## Get Schedules
```
    velero get schedules
```