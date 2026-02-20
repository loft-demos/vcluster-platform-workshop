# Install vCluster Platform with vind

vCluster in Docker (vind) allows you to deploy a complete Kubernetes cluster using Docker containers. This allows installing vCluster Platform anywhere you can run Docker.

1. Install the vCluster CLI: 
   - **Mac (Silicon/Arm):** 

    ```bash
    curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.32.0/vcluster-darwin-arm64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
    ```

   - **Windows:**

    ```bash
    md -Force "$Env:APPDATA\vcluster"; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12';
    Invoke-WebRequest -URI "https://github.com/loft-sh/vcluster/releases/download/v0.32.0/vcluster-windows-amd64.exe" -o $Env:APPDATA\vcluster\vcluster.exe;
    $env:Path += ";" + $Env:APPDATA + "\vcluster";
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User);
    ```

2. Configure the vCluster CLI to use the `docker` driver (the default driver is `helm`):

```bash
vcluster use driver docker
```

3. Create `vcluster.yaml` file with the following content:

```yaml
experimental:
  docker:
    nodes:
    - name: "worker-1"
      env:
        - "NODE_ROLE=worker"
    - name: "worker-2"
      env:
        - "NODE_ROLE=worker"
  deploy:
    vcluster:
      helm:
        - chart:
            name: ingress-nginx
            repo: https://kubernetes.github.io/ingress-nginx
            version: 4.14.1
          values: |-
            controller:
              service:
                type: LoadBalancer
              ingressClassResource:
                default: true
              admissionWebhooks:
                enabled: false
                patch:
                  enabled: false
          release:
            name: ingress-nginx
            namespace: ingress-nginx
        - chart:
            name: vcluster-platform
            repo: https://charts.loft.sh/
            version: 4.7.0-rc.3
          values: |-
            config:
              costControl:
                enabled: false
              imageBuilder:
                enabled: false
          release:
            name: vcluster-platform
            namespace: vcluster-platform
```

This creates a full Kubernetes cluster with 3 nodes (1 control plane node and 2 worker nodes) inside Docker containers and installs ingress-nginx and vCluster Platform into that vCluster Standalone cluster.

4. Create vCluster Standalone Kubernetes cluster with: `vcluster create vcp-cluster --upgrade --values vcluster.yaml`.
5. Verify the vCluster Standalone Kubernetes cluster:

```bash
kubectl get nodes
kubectl get namespaces
```

6. Retrieve the vCluster Labs hosted domain for vCluster Platform:

```bash
PLATFORM_NAMESPACE=vcluster-platform

echo "Waiting for vCluster Platform router domain..."

kubectl wait \
  --for=condition=Available \
  deployment/loft \
  -n $PLATFORM_NAMESPACE \
  --timeout=120s

until kubectl -n $PLATFORM_NAMESPACE get secret loft-router-domain >/dev/null 2>&1; do
  sleep 2
done

DOMAIN=$(kubectl get secret loft-router-domain \
  -n $PLATFORM_NAMESPACE \
  -o jsonpath="{.data.domain}" | base64 --decode 2>/dev/null || base64 -D)

echo "Open: https://${DOMAIN}"
```

7. Open the vCluster Platform hosted domain in your browser and login with `username: admin` and `password: my-password`. These credentials are the default bootstrap credentials configured by the Helm chart. You can override them via the vCluster Platform chart values.
8. After logging into vCluster Platform follow the on-screen instructions to get your vCluster Platform activation code (ensuring that you use a valid email for the activation code).

## Troubleshooting

- If `vcluster create` hangs → ensure Docker is running.
- If the domain does not resolve → verify the `loft-router-domain` secret exists.
- If ingress returns 404 → verify ingress-nginx is running: `kubectl -n ingress-nginx get pods`