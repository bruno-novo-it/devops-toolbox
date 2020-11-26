# Devops-toolbox

This a repository for DevOps Tools

## How Convert Helm2 to Helm 3

```sh
helm plugin install https://github.com/helm/helm-2to3.git

helm 2to3 move config --dry-run # will test the process

helm 2to3 convert CHART_NAME

helm 2to3 cleanup # Clean all Helm2 installation
```
