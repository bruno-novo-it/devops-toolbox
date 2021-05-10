# DevOps Toolbox Base Image, using Phusion Base Image

This is the a docker base image that contains:

```sh
Kubectl
Terraform
Docker
Helm
Gcloud --> Google Cloud Command Cli
Azure Cli
PowerShell
AWS Cli
Python3
And a lot of network and useful tools
```

To build the image, just execute:

```sh
docker build -t devops-toolbox .
```

Tha base image is a distribution from Phusion Docker Image --> `https://hub.docker.com/r/phusion/baseimage/`
