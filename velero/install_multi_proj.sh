#!/usr/bin/env bash

# https://hub.helm.sh/charts/vmware-tanzu/velero
# https://github.com/vmware-tanzu/helm-charts

# https://hub.docker.com/r/velero/velero
# https://hub.docker.com/r/velero/velero-plugin-for-gcp

# https://artifacthub.io/packages/helm/vmware-tanzu/velero


if [[ -z "$1" || -z "$2" || -z "$3" ]]
then
 echo "Project ID Origin, Project ID Destiny and Cluster name Destiny are needed!"
 exit 1
fi

export PROJECT_ID_ORIGIN=$1

export PROJECT_ID_DESTINY=$2

export CLUSTER_NAME_DESTINY=$3

export REGION=$(gcloud container clusters list --project ${PROJECT_ID_DESTINY} \
    --filter="name=${CLUSTER_NAME_DESTINY}" \
    --format="value(location)")

export BUCKET="${PROJECT_ID_ORIGIN}-bkp-velero"

# Create Service Account for Velero
gcloud iam service-accounts create velero --display-name="Velero service account" --project ${PROJECT_ID_DESTINY}

# Get Service Account Name
export SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --filter="displayName:Velero service account" --format='value(email)' --project ${PROJECT_ID_DESTINY})
echo ${SERVICE_ACCOUNT_EMAIL}

# Create Velero Bucket
# gsutil mb -l ${REGION} gs://${BUCKET}/ --project ${PROJECT_ID_ORIGIN}

# Create Roles if necessary
export ORGANIZATION_ID=137746208432
export ROLE_NAME=VeleroServer

if [[ `gcloud iam roles list --organization=$ORGANIZATION_ID --filter="title:${ROLE_NAME}" --format=json` == "[]" ]]
then
  echo "Custom Role VeleroServer Do not Exist, creating..."
       export ROLE_YAML_FILE=${ROLE_NAME}.yaml
       export ROLE_COMMAND=create

       gcloud iam roles ${ROLE_COMMAND} ${ROLE_NAME} --organization=$ORGANIZATION_ID --file=${ROLE_YAML_FILE} --quiet
else
  echo "Custom Role VeleroServer is already created"
fi

# Associate Created Role with Service Account
gcloud projects add-iam-policy-binding ${PROJECT_ID_DESTINY} \
       --member serviceAccount:${SERVICE_ACCOUNT_EMAIL} \
       --role="organizations/${ORGANIZATION_ID}/roles/${ROLE_NAME}" \
       --no-user-output-enabled

# Associate Created Role with Service Account
gcloud projects add-iam-policy-binding ${PROJECT_ID_ORIGIN} \
       --member serviceAccount:${SERVICE_ACCOUNT_EMAIL} \
       --role="organizations/${ORGANIZATION_ID}/roles/${ROLE_NAME}" \
       --no-user-output-enabled

# Associate Service Account with Bucket
gsutil iam ch serviceAccount:${SERVICE_ACCOUNT_EMAIL}:objectAdmin gs://$BUCKET

# Create Service Account Key
gcloud iam service-accounts keys create credentials-velero --iam-account=$SERVICE_ACCOUNT_EMAIL --project ${PROJECT_ID_DESTINY}

# Connect to Cluster
gcloud container clusters get-credentials ${CLUSTER_NAME_DESTINY} --region ${REGION} --project ${PROJECT_ID_DESTINY}

# Creating NameSpace Velero
NAMESPACE=velero
kubectl create ns ${NAMESPACE} || true

# Create Velero secret
kubectl create secret generic credentials-velero --namespace velero --from-file cloud=credentials-velero

# Adding Velero Repo
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts

# Update Cluster repositories
helm repo update

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

# Install Velero Helm Chart
helm upgrade --install velero \
             --namespace ${NAMESPACE} \
             --set-file credentials.secretContents.cloud=${CREDENTIAL_NAME} \
             --set configuration.provider=$CONFIGURATION_PROVIDER \
             --set configuration.backupStorageLocation.name=$BACKUP_STORAGE_LOCATION_NAME \
             --set configuration.backupStorageLocation.bucket=$BACKUP_STORAGE_LOCATION_BUCKET \
             --set configuration.volumeSnapshotLocation.name=$VOLUME_SNAPSHOT_LOCATION_NAME \
             --set configuration.volumeSnapshotLocation.config.snapshotLocation=$VOLUME_SNAPSHOT_LOCATION_CONFIG_REGION \
             --set configuration.volumeSnapshotLocation.config.project=${PROJECT_ID_ORIGIN} \
             --set image.repository=$VELERO_IMAGE_REPOSITORY_NAME \
             --set image.tag=$VELERO_IMAGE_TAG \
             --set image.pullPolicy=IfNotPresent \
             --set initContainers[0].image=${VELERO_PLUGIN_IMAGE} \
             --set initContainers[0].name=${VELERO_PLUGIN_NAME} \
             --set initContainers[0].volumeMounts[0].mountPath=/target \
             --set initContainers[0].volumeMounts[0].name=plugins \
             -f ${VALUES_FILE} \
             vmware-tanzu/velero


#More info on the official site: https://velero.io/docs

# Removing unnecessary files
rm -rf credentials-velero
