# Install vCluster Platform Using vCluster in Docker (vind)

vCluster in Docker (vind) allows you to run a complete Kubernetes cluster inside Docker containers. This makes it possible to install and experiment with vCluster Platform on any machine that supports Docker — without requiring external cloud infrastructure.

1. Install or upgrade the vCluster CLI: 
   - **Mac (Silicon/Arm):** 

    ```bash
    curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.33.0-alpha.0/vcluster-darwin-arm64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
    ```

   - **Windows Powershell:**

    ```bash
    md -Force "$Env:APPDATA\vcluster"; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12';
    Invoke-WebRequest -URI "https://github.com/loft-sh/vcluster/releases/download/v0.33.0-alpha.0/vcluster-windows-amd64.exe" -o $Env:APPDATA\vcluster\vcluster.exe;
    $env:Path += ";" + $Env:APPDATA + "\vcluster";
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User);
    ```

  - Verify with the following to ensure you have `vcluster version 0.33.0-alpha.0`:

    ```bash
    vcluster version
    ```
  > [!IMPORTANT]
  > If you have another version of the vCluster CLI other than `0.33.0-alpha.0`, ensure that you update the vCluster CLI with the same method you originally installed it. Here are [some vCluster CLI installation examples](https://www.vcluster.com/docs/vcluster/#deploy-vcluster).

1. Create `vcluster.yaml` file with the following content:

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
            version: 4.7.0
          values: |-
            config:
              # only uncomment if you have your own FQDN to use for vCluster Platform
              # loftHost: "<your-fully-qualifed-domain-name>"
              costControl:
                enabled: false
              imageBuilder:
                enabled: false
          release:
            name: vcluster-platform
            namespace: vcluster-platform
```

This [*vcluster.yaml*](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/) configuration creates a vCluster Standalone Kubernetes cluster with three nodes (one control plane and two workers) running inside Docker containers.

It then installs ingress-nginx and vCluster Platform into that cluster, providing a complete local environment for this workshop.

> [!NOTE]
> If you use your own FQDN for vCluster Platform, then you will need to [configure external access and TLS for vCluster Platfrom](https://www.vcluster.com/docs/platform/configure/installation-options/domain)

3. Create vCluster Standalone Kubernetes cluster using vCluster-in-Docker (vind):

```bash
vcluster create vcp-cluster --driver docker --upgrade --values vcluster.yaml
```

> [!NOTE]
> If you are using Docker Desktop, you may have to run the above command with `sudo` for permissions to create the `LoadBalancer` for the ingress-nginx install.

The `--driver docker` flag enables **vCluster-in-Docker (vind)** mode. Instead of deploying into an existing Kubernetes cluster, this command creates a complete Kubernetes cluster inside Docker containers and applies the configuration defined in vcluster.yaml.

By default, the vCluster CLI uses the `helm` driver, which deploys into the current `kube-context` of a pre-existing Kubernetes cluster. Specifying `--driver docker` ensures this lab is fully self-contained and does not depend on any external cluster.

4. Verify the vCluster Standalone Kubernetes cluster:

```bash
kubectl get nodes
kubectl get namespaces
```

5. If `loftHost` is not configured with your own fully qualified domain name (FQDN), vCluster Platform automatically provisions a secure, randomly generated domain for the installation.

For local environments such as vind, using this automatically generated domain is the simplest option. It provides immediate HTTPS access to the platform UI and API without requiring you to configure DNS records, ingress hosts, or certificates on your machine.

The generated domain is stored in the `loft-router-domain` secret in the installation namespace and can be retrieved with the following:

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

6. Open the vCluster Platform hosted domain in your browser and log in with:

- `username: admin`
- `password: my-password`

These credentials are the default bootstrap credentials defined by the Helm chart. You can override them via the vCluster Platform chart values.

7. After logging into vCluster Platform follow the on-screen instructions to retrieve and enter your vCluster Platform activation code.

> [!NOTE]
> You will need a valid email address to receive your vCluster Platform activation code.  
> Activating your installation enables the [**Free tier** of vCluster Platform](https://www.vcluster.com/docs/platform/free-vs-enterprise), which is sufficient for completing this workshop.

8. Verify that the ingress-nginx controller was deployed successfully and has a `LoadBalancer` ip address:

```bash
kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

> [!WARNING]
> This vind-based environment is intended for local development and workshop use.  
> For production deployments, configure `loftHost` with your organization’s domain and TLS configuration.

## What's Next

Continue with the [Shared Nodes Tenancy Model Lab](/labs/tenancy-models/shared-nodes.md)

## Troubleshooting

- If `vcluster create` hangs → ensure Docker is running.
- If the domain does not resolve → verify the `loft-router-domain` secret exists.
- If ingress returns 404 → verify ingress-nginx is running: `kubectl -n ingress-nginx get pods`
