# Shared Nodes Tenancy Model

The Shared Nodes tenancy model allows multiple virtual clusters to run workloads on the same physical Kubernetes nodes, with the vCluster syncing resources to and from the host cluster. The control plane of the vCluster is deployed as a `Pod` on a host cluster while vCluster workload `Pods` are synced  to and then scheduled on the host cluster worker nodes. This configuration is ideal for scenarios where maximizing resource utilization is a top priority—especially for internal developer environments, CI/CD pipelines, and cost-sensitive use cases.

## Lab Overview

In this lab you will:

- Use vCluster Platform to create a virtual cluster instance that uses the shared node tenancy model.
- Deploy a workload into the shared node virtual cluster.
- Configure the shared node virtual cluster to sync a resource from the host cluster into the virtual cluster.
- Configure a shared node virtual cluster to sync a custom resource to the host cluster.

### Create a Basic Shared Node Virtual Cluster

1. Navigate to the *Virtual Clusters* view of the *Default Project* and click on the *Create virtual cluster* button.
2. Next, select *Deploy with vCluster Platform* and then click the *Continue without template* button (we will explore templates later in this workshop).
3. On the next screen, under **Config Options**:
   - Enter *Shared Nodes vCluster* for the **Virtual Cluster Name**
   - Under **Backing Store Type**, select *Embedded Etcd* - embedded etcd starts the etcd binary with the Kubernetes control plane inside the vCluster pod allowing for highly-available, fully managed backing store for the vCluster control plane.
4. Note that the **vcluster.yaml** has been updated to reflect the changes made in the UI - in addition to the vCluster Platform default **vcluster.yaml** configuration that enabled syncing `Ingress` resources to the host cluster and enabled embedded CoreDNS that allows running CoreDNS as part of the syncer, which saves the resources of an additional CoreDNS pod:

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
6. Once your *Shared Nodes vCluster* is up an running click on the **Inspect Resources** button - under and to the right of the **Control Plane Pods Status** - to view the Kubernetes resources inside of the *Shared Nodes vCluster*. Click on **Nodes** and you will see *No Node found*. That is because `Nodes` only appear in a shared nodes vCluster once a vCluster workload `Pod` is created in the vCluster and synced to the host cluster.

> [!Note]
> By default, the host nodes are not synced from the host cluster to the virtual cluster and are considered pseudo nodes. Pseudo nodes have real values for name, but everything else is randomly generated.
> 
> When you run `kubectl get nodes`, the only nodes that show up are the ones that have pods scheduled on them. Any information besides the name is randomly generated. If there are no more pods on that host node, vCluster deletes the pseudo node in the virtual cluster. [Learn more about host nodes for shared node virtual clusters](https://www.vcluster.com/docs/vcluster/deploy/worker-nodes/host-nodes/).

7. In addition to the **Inspect Resources** view, vCluster Platform provides an integrated [**Kubectl Shell** feature](https://www.vcluster.com/docs/platform/4.6.0/use-platform/virtual-clusters/key-features/kubectl-shell) feature. This launches a temporary, browser-based terminal connected to a pod inside the target vCluster using a scoped [`AccessKey`](https://www.vcluster.com/docs/platform/4.6.0/administer/authentication/access-keys), allowing you to run `kubectl` commands directly from the vCluster Platform UI. To open the **Kubectl Shell**, click the *More* options **⋮** menu next to the **Connect** button in the top-right corner, then select **Kubectl Shell**. A terminal will open at the bottom of the screen.
8. Run the following `kubectl` command inside the **Kubectl Shell: shared-nodes-vcluster** terminal:

```bash
kubectl get nodes --show-labels
kubectl get ns
kubectl apply -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/podinfo-deploy.yaml
```

This will create a `Namespace` called demo inside of the vCluster and deploy the [podinfo](https://github.com/stefanprodan/podinfo?tab=readme-ov-file#podinfo) app into that `Namespace` - click [here](https://github.com/stefanprodan/podinfo?tab=readme-ov-file#podinfo) to see the complete Kubernetes manifests that were applied. Also, the reason there is now a `node`

9. Next, run the following commands to see that there is a new *demo* `Namespace` and that the *podinfo* app was deployed into that `Namespace`:

```bash
kubectl get nodes --show-labels
kubectl get ns
kubectl get all -n demo
```

10. Now click on the **loft-default-v-shared-nodes-vcluster** link at the top-middle of the vCluster Config page to view the host `namespace` where your *Shared Nodes vCluster* control plane `pod` is running and to see what resource got synced from your *Shared Nodes vCluster* to the host cluster. You will see the **podinfo** `pod` with a name similar to *podinfo-7cc755bcdb-dtz8h-x-demo-x-shared-nodes-vcluster* (along with the *Shared Nodes vCluster* control plane `pod` *shared-nodes-vcluster-0*).
11. Next, click on the **Ingresses** tab and you will see that the **podinfo** `ingress` resource was also synced to the host cluster because your *Shared Nodes vCluster* was configured with `sync.toHost.ingresses.enabled: true`. Note that it has the same  `ip` address of the ingress-nginx
12. Open that ip address with the path `/podinfo/` - so your URL will be `http://<your-loadbalancer-ip>/podinfo/` and you will see the **podinfo** app that you deployed into your *Shared Nodes vCluster* even thought there is no ingress controller running in your vCluster. You are able to use the shared host cluster ingress controller by enable the syncing of `ingress` resources `toHost`.
13. 

### Syncing Resources From the Host Cluster


We also want to sync `StorageClass` resources from the host cluster into the vCluster by updating the **vcluster.yaml** to match the following (this cannot be configured via the UI directly):

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

7. Inside the **Kubectl Shell: shared-nodes-vcluster** run the following `kubectl` command and you will see that the `local-path` `StorageClass` has been synced from the host cluster:

```bash
kubectl get storageclasses
```



Syncing resources is a distinct feature of the **Share Node** tenancy model.