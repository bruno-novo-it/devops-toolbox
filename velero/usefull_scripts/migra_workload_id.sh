#!/bin/bash

PROJECT_ID_1=$1
GKE_CLUSTER_NAME_1=$2
PROJECT_ID_2=$3
GKE_CLUSTER_NAME_2=$4
REGION="southamerica-east1"

if [[ -z ${PROJECT_ID_1} || -z ${GKE_CLUSTER_NAME_1} || -z ${PROJECT_ID_2} || -z ${GKE_CLUSTER_NAME_2} ]]
then
  echo "================================="
  echo "Informe os 4 parametros abaixo:"
  echo "  > PROJECT_ID de Origem"
  echo "  > GKE_CLUSTER_NAME de Origem"
  echo "  > PROJECT_ID de Destino"
  echo "  > GKE_CLUSTER_NAME de Destino"
  echo "================================="
  echo "Exemplo:"
  echo "$0 PROJECT_ID_ORIGEM GKE_CLUSTER_NAME_ORIGEM PROJECT_ID_DESTINO GKE_CLUSTER_NAME_DESTINO"
  echo "$0 uat-bv uat bv-gke-shared-uat gke-shared-uat"
  echo "================================="
  exit 1
fi

IS_PROJECT_ID_1=$(gcloud projects list | awk '{print $1}' | awk 'NR>1'  |grep -w $PROJECT_ID_1)
if [[ -z ${IS_PROJECT_ID_1} ]]
then
  echo "O Projeto de Origem $PROJECT_ID_1 nao existe na GCP."
  exit 2
fi

IS_PROJECT_ID_2=$(gcloud projects list | awk '{print $1}' | awk 'NR>1'  |grep -w $PROJECT_ID_2)
if [[ -z ${IS_PROJECT_ID_2} ]]
then
  echo "O Projeto de Destino $PROJECT_ID_2 nao existe na GCP."
  exit 2
fi

IS_GKE_CLUSTER_NAME_1=$(gcloud container clusters list --project ${PROJECT_ID_1} | grep -w ${GKE_CLUSTER_NAME_1} |awk '{print $1}')
if [[ -z ${IS_GKE_CLUSTER_NAME_1} ]]
then
  echo "GKE cluster $GKE_CLUSTER_NAME_1 nao existe no projeto ${PROJECT_ID_1}"
  exit 2
fi

IS_GKE_CLUSTER_NAME_2=$(gcloud container clusters list --project ${PROJECT_ID_2} | grep -w ${GKE_CLUSTER_NAME_2} |awk '{print $1}')
if [[ -z ${IS_GKE_CLUSTER_NAME_2} ]]
then
  echo "GKE cluster $GKE_CLUSTER_NAME_2 nao existe no projeto ${PROJECT_ID_2}"
  exit 2
fi

echo "Connecting on Project ${PROJECT_ID_1} and Cluster ${GKE_CLUSTER_NAME_1}..." 
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME_1} --region ${REGION} --project ${PROJECT_ID_1}

# Pegando a lista de SAs
for x in $(kubectl get sa -A |grep -vi Default |awk '/^des|^qa|^uat|^prd/{print $1"|"$2}'); do 
    ns=$(echo $x |awk -F \| '{print $1}'); 
    sa=$(echo $x |awk -F \| '{print $2}');

    # Validando SA que tem o annotation do Workload_id
    annot=$(kubectl describe sa $sa -n $ns |grep 'iam.gke.io/gcp-service-account');
    if [[ -n $annot ]]; then
        G_PROJECT_ID=$(echo $annot |awk -F \@ '{print $2}' | awk -F \. '{print $1}')
        GSA=$(echo $annot |awk '{print $3}' |awk -F \@ '{print $1}')
        echo "=============================================================="
        echo "=== Ajustando SA $sa do Namespace $ns"

        # Aplicando o binding no IAM da GCP para o cluster novo
        gcloud iam service-accounts add-iam-policy-binding \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:$PROJECT_ID_2.svc.id.goog[$ns/$sa]" \
        $GSA@$G_PROJECT_ID.iam.gserviceaccount.com --project $G_PROJECT_ID
    fi  
done
echo ""
echo "#### FIM ####"


