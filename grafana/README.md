# Grafana Helm Installation

## How to get Grafana Admin Password

### 1. Get your 'admin' user password by running:

```sh
   kubectl get secret --namespace istio-system grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

### 2. The Grafana server can be accessed via port 3000 on the following DNS name from within your cluster:

```sh
   grafana.istio-system.svc.cluster.local
```

   Get the Grafana URL to visit by running these commands in the same shell:

```sh
     export POD_NAME=$(kubectl get pods --namespace istio-system -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace istio-system port-forward $POD_NAME 3000
```

### 3. Login with the password from step 1 and the username: admin