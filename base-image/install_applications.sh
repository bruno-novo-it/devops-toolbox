#!/bin/bash

## This tool allows installation of apt packages with automatic cache cleanup: install_clean

install_clean vim-tiny \
		psmisc \
		unzip \
		jq \
		lsb-core \
		gnupg-agent \
		git \
		iputils-ping \
                iproute2 \
		netcat \
		tcpdump \
		telnet \
                net-tools \
                inetutils-traceroute \
		dnsutils \
                ca-certificates \
                curl \
                apt-transport-https \
                lsb-release \
                gnupg \
                s-nail \
                lsof \
                procps \

## Install Powershell
curl -LO https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
        apt-get install ./packages-microsoft-prod.deb && \
        apt-get update && \
        install_clean powershell


## Install Kubectl
export KUBECTL_VERSION=`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt` && \
        curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /usr/local/bin/kubectl

## Install Helm3
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
        chmod 700 get_helm.sh && \
        ./get_helm.sh && \
        rm -f get_helm.sh

## Install Terraform
export TERRAFORM_VERSION=`curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version'` && \
        curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
        unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        chmod a+x terraform && \
        mv terraform /usr/local/bin/ && \
        rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
        terraform version

## Install GCloud SDK
echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
        install_clean google-cloud-sdk

## Install Azure Cli
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
apt-get update && install_clean azure-cli

## AWSCLI
DEBIAN_FRONTEND=noninteractive install_clean awscli -q

## Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
        install_clean docker-ce docker-ce-cli containerd.io

## Install Python3 and some modules
install_clean python3-setuptools python3-pip && pip3 install requests

## Clean Environment
./bd_build/cleanup.sh
rm -rf bitbucket_manager.py install_applications.sh *.deb