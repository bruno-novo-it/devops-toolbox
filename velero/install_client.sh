#!/bin/bash

# https://velero.io/docs/v1.2.0/basic-install/#install-the-cli

VERSION=v1.6.3
DISTRIBUTION=linux-amd64



wget https://github.com/vmware-tanzu/velero/releases/download/${VERSION}/velero-${VERSION}-${DISTRIBUTION}.tar.gz

tar -xvf velero-${VERSION}-${DISTRIBUTION}.tar.gz

sudo mv velero-${VERSION}-${DISTRIBUTION}/velero /usr/bin

sudo chmod a+x /usr/bin/velero

rm -rf velero-${VERSION}-${DISTRIBUTION}.tar.gz velero-${VERSION}-${DISTRIBUTION}




#Once velero server is up and running you need the client before you can use it
#1. wget https://github.com/vmware-tanzu/velero/releases/download/v1.5.2/velero-v1.5.2-darwin-amd64.tar.gz
#2. tar -xvf velero-v1.5.2-darwin-amd64.tar.gz -C velero-client