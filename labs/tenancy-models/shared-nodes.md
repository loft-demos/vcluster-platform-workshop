# Shared Nodes Tenancy Model

The **Shared Nodes** tenancy model allows multiple virtual clusters to run workloads on the same physical Kubernetes nodes, with the vCluster syncing resources to and from the host cluster. The control plane of the vCluster is deployed as a `Pod` on a host cluster while vCluster workload `Pods` are synced  to and then scheduled on the host cluster worker nodes. This configuration is ideal for scenarios where maximizing resource utilization is a top priority—especially for internal developer environments, CI/CD pipelines, and cost-sensitive use cases.

![Shared Nodes Architecture](https://www.vcluster.com/docs/assets/images/shared-nodes-db4220d444d97681ca3b7f394a8ea81f.png)

## Lab Overview

In this lab you will:

- Use vCluster Platform to create a virtual cluster instance that uses the shared nodes tenancy model.
- Deploy a workload into the shared nodes virtual cluster.
- Configure the shared nodes virtual cluster to sync a resource from the host cluster into the virtual cluster.
- Configure a shared nodes virtual cluster to sync a custom resource to the host cluster.

## Lab Exercises

### Create a Basic Shared Node Virtual Cluster

This lab exercise walks you through creating a basic Shared Nodes virtual cluster using vCluster Platform and exploring how workloads are synced from the virtual cluster to the host cluster. You will deploy a sample application, observe pseudo nodes appearing inside the vCluster, and verify how resources like Pods and Ingresses are synchronized and scheduled onto shared host nodes.

1. Navigate to your vCluster Platform domain in your browser and click on the **Virtual Clusters** link in the top-left menu under view of the **Default Project**, and then click on the **Create virtual cluster** button.
2. Next, click **Deploy with vCluster Platform** and then click the **Continue without template** button (we will explore templates later in this workshop).
3. On the next screen, under **Config Options**:
   - Enter *Shared Nodes vCluster* for the **Virtual Cluster Name**
   - Under **Backing Store Type**, select *Embedded Etcd*. This option runs the `etcd` binary alongside the Kubernetes control plane inside the vCluster `syncer` container, providing a fully managed and highly available data store for the vCluster control plane.
4. Note that the **vcluster.yaml** has been updated to reflect the changes made in the UI - in addition to the vCluster Platform default **vcluster.yaml** configuration that enabled syncing `Ingress` resources to the host cluster and enabled embedded CoreDNS that runs CoreDNS in the vCluster `syncer` container, which saves the resources of an additional CoreDNS pod:

```yaml
sync:
  toHost:
    ingresses:
      enabled: true
controlPlane:
  coredns:
    enabled: true
    embedded: true
  backingStore:
    etcd:
      embedded:
        enabled: true
```

> [!Note]
> The [`vcluster.yaml` configuration file](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/) defines how your virtual cluster operates and integrates with the host cluster. Use the `vcluster.yaml` file to configure vCluster. It allows you to override default settings by specifying resource sync rules, networking behavior, storage options, and authentication methods.

5. Next, click the **Create virtual cluster** button at the bottom right of the page.
6. Once your *Shared Nodes vCluster* is up an running, click on the **Inspect Resources** button - under and to the right of the **Control Plane Pods Status** - to view the Kubernetes resources inside your *Shared Nodes vCluster*. Click on **Nodes** and you will see *No Node found*. That is because `Nodes` only appear in a shared nodes vCluster once a vCluster workload `Pod` is created in the vCluster and synced to the host cluster.

> [!Note]
> By default, the host nodes are not synced from the host cluster to the virtual cluster and are considered pseudo nodes. Pseudo nodes have real values for name, but everything else is randomly generated.
> 
> When you run `kubectl get nodes`, the only nodes that show up are the ones that have pods scheduled on them. Any information besides the name is randomly generated. If there are no more pods on that host node, vCluster deletes the pseudo node in the virtual cluster. [Learn more about host nodes for shared node virtual clusters](https://www.vcluster.com/docs/vcluster/deploy/worker-nodes/host-nodes/).

7. In addition to the **Inspect Resources** view, vCluster Platform provides an integrated [**Kubectl Shell** feature](https://www.vcluster.com/docs/platform/4.6.0/use-platform/virtual-clusters/key-features/kubectl-shell). This launches a temporary, browser-based terminal connected to a `pod` inside the target vCluster using a scoped [`AccessKey`](https://www.vcluster.com/docs/platform/4.6.0/administer/authentication/access-keys), allowing you to run `kubectl` commands directly from the vCluster Platform UI. To open the **Kubectl Shell**, click the *More* options **⋮** menu next to the **Connect** button in the top-right corner, then select **Kubectl Shell**. A terminal will open at the bottom of the screen.
8. Run the following `kubectl` command inside the **Kubectl Shell: shared-nodes-vcluster** terminal:

```bash
kubectl get nodes --show-labels
kubectl get ns
kubectl apply -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/podinfo-deploy.yaml
```

This will create a `Namespace` called `demo` inside of the vCluster and deploy the [podinfo](https://github.com/stefanprodan/podinfo?tab=readme-ov-file#podinfo) app into that `Namespace` - click [here](https://github.com/stefanprodan/podinfo?tab=readme-ov-file#podinfo) to see the applied Kubernetes manifests. Also, the reason there is now a `node`

9. Next, run the following commands to see that there is a new *demo* `Namespace` and that the *podinfo* app was deployed into that `Namespace`:

```bash
kubectl get nodes --show-labels
kubectl get ns
kubectl get all -n demo
```

10. Now click on the **loft-default-v-shared-nodes-vcluster** link at the top-middle of the vCluster Config page to view the host `namespace` where your *Shared Nodes vCluster* control plane `pod` is running and to see what resource got synced from your *Shared Nodes vCluster* to the host cluster. You will see the **podinfo** `pod` with a name similar to *podinfo-7cc755bcdb-dtz8h-x-demo-x-shared-nodes-vcluster* (along with the *Shared Nodes vCluster* control plane `pod` *shared-nodes-vcluster-0*).
11. Next, click on the **Ingresses** tab and you will see that the **podinfo** `ingress` resource was also synced to the host cluster because your *Shared Nodes vCluster* was configured with `sync.toHost.ingresses.enabled: true`. Note that it has the same  `ip` address of the ingress-nginx
12. Open the ingress-nginx `LoadBalancer` ip address with the path `/podinfo/` appended to it - so your URL will be `http://<your-loadbalancer-ip>/podinfo/`. The web UI of the **podinfo** app that you deployed into your *Shared Nodes vCluster* will load; een though there is no ingress controller running in your vCluster. The **podinfo** `ingress` is reusing the ingress-nginx ingress controller deployed in the host cluster by syncing  `ingress` resources `toHost`.

### Syncing Resources From the Host Cluster

This lab exercise will explore syncing a `StorageClass` resources from the shared host cluster into your *Shared Nodes vCluster*.

vCluster can sync certain resources from the host cluster to make them available inside the virtual cluster, but when these resources are synced, they are only synced in read-only mode. No changes to the resource in the virtual cluster syncs back to the host cluster as the resources are shared across the host cluster.

1. Navigate to the **Default Project Overview** page and click on your *Shared Nodes vCluster*.
2. Under **Inspect Resources** click on **More resources...**, search for *Storage Class* and select it from the results. You will see that there are no `StorageClass` resources in your *Shared Nodes vCluster*.
3. Next, click on the **Config** menu item above **Inspect Resources** and under **Config Options**, scroll down to and expand the **Sync from Host** section. Note that this cannot be configured directly via the UI so you will need to add the configuration to the **vcluster.yaml** on the right.
4. Add the `fromHost` config block from the configuration below to your existing **vcluster.yaml** configuration (or just replace the entire config):

```yaml
sync:
  toHost:
    ingresses:
      enabled: true
  fromHost:
    storageClasses:
      enabled: true
controlPlane:
  coredns:
    enabled: true
    embedded: true
  backingStore:
    etcd:
      embedded:
        enabled: true
```

5. Click the **Save** button at the bottom-right of the page which will result in your *Shared Nodes vCluster* control plane restarting to load these config changes.
6. Once your *Shared Nodes vCluster* is running, navigate back to the **Storage Class** listing under **Inspect Resources** and you will see a `StorageClass` resource named *local-path*.

### Custom Resource Syncing

This lab exercise walks you through syncing the CloudNativePG (CNPG) `Cluster` custom resource from a virtual cluster to the host cluster. You’ll configure custom resource sync for the CNPG `Cluster` resource type and observe how the vCluster `syncer` detects and automatically syncs back the generated host resources, such as `Pods` and `Services`, into the virtual cluster.

CloudNativePG is an Operator that implements the Kubernetes controller pattern and creates additional resources (via `ownerReferences`), making it ideal for demonstrating bidirectional sync behavior.

1. Navigate to the **Default Project Overview** page, hover over your *Shared Nodes vCluster* and then click the **Edit** button on the right.
2. 

Update **vcluster.yaml** configuration:

```yaml
sync:
  toHost:
    ingresses:
      enabled: true
    secrets:
      enabled: true
    customResources:
      clusters.postgresql.cnpg.io/v1:
        enabled: true
        patches:
          # Rewrite references to superuser Secret when syncing to host
          - path: spec.superuserSecret.name
            reference:
              apiVersion: v1
              kind: Secret
  fromHost:
    storageClasses:
      enabled: true
controlPlane:
  coredns:
    enabled: true
    embedded: true
  backingStore:
    etcd:
      embedded:
        enabled: true
```

Create a cnpg `cluster` resoruce in your *Shared Nodes vCluster*.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cnpg-demo
---
# App DB user (used by bootstrap.initdb)
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: cnpg-demo
type: kubernetes.io/basic-auth
stringData:
  username: app
  password: app-password
---
# Postgres superuser password (postgres)
apiVersion: v1
kind: Secret
metadata:
  name: superuser-secret
  namespace: cnpg-demo
type: kubernetes.io/basic-auth
stringData:
  username: postgres
  password: postgres-password
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: demo-pg
  namespace: cnpg-demo
spec:
  instances: 1

  resources:
    requests:
      cpu: "250m"
      memory: "256Mi"
    limits:
      cpu: "1"
      memory: "1Gi"

  superuserSecret:
    name: superuser-secret

  bootstrap:
    initdb:
      database: app
      owner: app

  storage:
    size: 1Gi
    storageClass: local-path

  managed:
    roles:
      - name: reporting_user
        login: true
```

See resources synced back into your *Shared Nodes vCluster*.

## What's Next

Continue with the [Dedicated Nodes Tenancy Model Lab](/labs/tenancy-models/dedicated-nodes.md)