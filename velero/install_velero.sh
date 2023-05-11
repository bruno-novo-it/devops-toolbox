#!/usr/bin/env bash

# https://hub.helm.sh/charts/vmware-tanzu/velero
# https://github.com/vmware-tanzu/helm-charts

# https://hub.docker.com/r/velero/velero
# https://hub.docker.com/r/velero/velero-plugin-for-gcp

# https://artifacthub.io/packages/helm/vmware-tanzu/velero


# Adding Velero Repo
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts

# Update Cluster repositories
helm repo update

NAMESPACE=velero
CREDENTIAL_NAME=credentials-velero
CONFIGURATION_PROVIDER=gcp
BACKUP_STORAGE_LOCATION_NAME=default
BACKUP_STORAGE_LOCATION_BUCKET=$BUCKET
BACKUP_STORAGE_LOCATION_CONFIG_REGION=$REGION
VOLUME_SNAPSHOT_LOCATION_NAME=default
VOLUME_SNAPSHOT_LOCATION_CONFIG_REGION=$REGION
VELERO_IMAGE_REPOSITORY_NAME=docker.io/velero/velero
VELERO_IMAGE_TAG=v1.6.3
VELERO_PLUGIN_IMAGE=velero/velero-plugin-for-gcp:v1.2.0
VELERO_PLUGIN_NAME=velero-plugin-for-gcp
VALUES_FILE=values.yaml

# Creating NameSpace Velero
kubectl create ns ${NAMESPACE} || true

# Install Velero Helm Chart
helm upgrade --install velero \
             --namespace ${NAMESPACE} \
             --set-file credentials.secretContents.cloud=${CREDENTIAL_NAME} \
             --set configuration.provider=$CONFIGURATION_PROVIDER \
             --set configuration.backupStorageLocation.name=$BACKUP_STORAGE_LOCATION_NAME \
             --set configuration.backupStorageLocation.bucket=$BACKUP_STORAGE_LOCATION_BUCKET \
             --set configuration.volumeSnapshotLocation.name=$VOLUME_SNAPSHOT_LOCATION_NAME \
             --set configuration.volumeSnapshotLocation.config.snapshotLocation=$VOLUME_SNAPSHOT_LOCATION_CONFIG_REGION \
             --set image.repository=$VELERO_IMAGE_REPOSITORY_NAME \
             --set image.tag=$VELERO_IMAGE_TAG \
             --set image.pullPolicy=IfNotPresent \
             --set initContainers[0].image=$VELERO_PLUGIN_IMAGE \
             --set initContainers[0].name=${VELERO_PLUGIN_NAME} \
             --set initContainers[0].volumeMounts[0].mountPath=/target \
             --set initContainers[0].volumeMounts[0].name=plugins \
             -f ${VALUES_FILE} \
             vmware-tanzu/velero


#More info on the official site: https://velero.io/docs

# Removing unnecessary files
rm -rf credentials-velero
