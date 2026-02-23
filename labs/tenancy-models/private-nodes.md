# Private Nodes Tenancy Model

In the **Private Nodes** tenancy model, the vCluster control plane is still deployed as a `Pod` on the host cluster — just like with the Shared Nodes tenancy.

However, unlike Shared Nodes:
- No Kubernetes resources are synced to the host cluster.
- WWorkloads run on worker nodes that join directly to the virtual cluster.
- The Private Nodes vCluster must include its own Kubernetes scheduler ([the Kubernetes scheduler is optional with Shared Nodes virtual clusters](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/control-plane/other/advanced/virtual-scheduler)).
- Infrastructure components such as CNI and CSI drivers must be installed inside the vCluster.

Worker nodes must be provisioned and explicitly joined — either manually or automatically using [vCluster **Auto Nodes**](https://www.vcluster.com/docs/vcluster/deploy/worker-nodes/private-nodes/auto-nodes/).

## Lab Overview

In this lab, you will:

- Create a virtual cluster using the **Private Nodes** tenancy model.
- Observe that no worker `nodes` are present in the vCluster.
- Confirm that `pods` remain in a `Pending` state.
- Manually join a worker node.
- Deploy a sample application.
- Verify that `pods` are scheduled and running on the joined `node`.

By the end of this lab, you will understand how Private Nodes isolate workloads by running them on nodes that register directly to the virtual cluster — rather than the host cluster.

## Lab Exercises

### Create a Basic Private Node Virtual Cluster

This lab exercise walks you through creating a basic Private Nodes virtual cluster using vCluster Platform.  You will observe that there are no worker `nodes` so `pods` cannot be scheduled.

1. Navigate to your vCluster Platform domain in your browser and click on the **Virtual Clusters** link in the top-left menu under view of the **Default Project**, and then click on the **Create virtual cluster** button.
2. Next, click **Deploy with vCluster Platform** and then click the **Continue without template** button (we will explore templates later in this workshop).
3. On the next screen, under **Config Options**:
   - Enter *Private Nodes vCluster* for the **Virtual Cluster Name**
   - For the **Tenancy Model** select **Private Nodes**
   - Under **Backing Store Type**, select *Embedded Etcd*
   - Expand the **Networking** configuration and check **Enable vCluster VPN**

> [!IMPORTANT]
> It is important that you configure the **Tenancy Model** before configuring anything else in the UI.

> [!NOTE]
> [vCluster VPN](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/private-nodes/vpn) allows you to connect the private worker nodes to a Private Nodes vCluster control plane through vCluster Platform. This is useful in scenarios where the nodes cannot reach the control plane directly, for example if you cannot use `LoadBalancer` or `NodePort` type services, but nodes can reach the vCluster Platform URL.

4. Veriry that your **vcluster.yaml** on the right matches the following:

```yaml
privateNodes:
  enabled: true
  vpn:
    enabled: true
networking:
  podCIDR: 10.64.0.0/16
  serviceCIDR: 10.128.0.0/16
controlPlane:
  backingStore:
    etcd:
      embedded:
        enabled: true
```

5. Click the **Create virtual cluster** button at the bottom right of the page.
6. Once your *Private Nodes vCluster* is up an running, click on the **Inspect Resources** button - under and to the right of the **Control Plane Pods Status** - to view the Kubernetes resources inside your *Private Nodes vCluster*.
7. Click on **Nodes** and you will see *No Nodes Attached to Cluster*. That is because `Nodes` must be provisioned and joined for a Private Nodes virtual cluster.
8. Click to view your *Private Nodes vCluster* **Pods** and note that they all of a ***Pending*** **Status**.

### Manually Join a Worker Node

This lab exercise walks you through manually attaching a worker node to your *Private Nodes vCluster*.

1. Navigate to the **Default Project Overview** page and click on your *Private Nodes vCluster*.
2. Click on **Nodes** and then click on **Attach Node Directly...** button.
3. Follow the instructions to attach a node to your *Private Nodes vCluster*. You should end up with a join command similar to this one: `curl -fsSLk "https://8irwjhj.loft.host/kubernetes/project/default/virtualcluster/private-nodes-vcluster/node/join?token=kvd5r2.9tkwwgfxpfgee4mi" | sh -`
4. Now that you have the command to attach a node to your *Private Nodes vCluster* you need a node to attach. Run the following command to create a VM in a Docker container:

```bash
docker run -d \
  --name vcluster.node.private-nodes-vcluster.worker-1 \
  --hostname worker-1 \
  --privileged \
  --stop-timeout 1 \
  -v vcluster.node.private-nodes-vcluster.worker-1-run:/run \
  -v vcluster.node.private-nodes-vcluster.worker-1-containerd:/var/lib/containerd \
  -v vcluster.node.private-nodes-vcluster.worker-1-kubelet:/var/lib/kubelet \
  -v vcluster.node.private-nodes-vcluster.worker-1-vcluster:/var/lib/vcluster \
  ghcr.io/loft-sh/vm-container
```

5. Once the `vm-container` is up and running run the following commands to `exec` into that container and run the connection command you created above with the token to join the `vm-container` as a worker `node`, noting that you will have to replace the ip address with the one for your control plane node and the token with the one from your join command:

```bash
docker exec -it vcluster.node.private-nodes-vcluster.worker-1 bash
```

> Then inside the `vm-container`:

```bash
curl -fsSLk "https://<replace-with-your-vcp-host>/kubernetes/project/default/virtualcluster/private-nodes-vcluster/node/join?token=<replace-with-your-join-tokne>" | sh -
exit
```

1. After the join script has completed setting up the worker node, return to the **Inspect Resources** view of your *Private Nodes vCluster* and select **Nodes**. You will see that you now have a worker node connected to yourm*Private Nodes vCluster*.
2. Click **Pods** and you will see that the they are either *Running* or starting.

### Deploy a Workload to Your *Private Nodes vCluster*

This lab exercise walks you through deploying a workload to your *Private Nodes vCluster* and explores how it is different than a workload deployed to your *Shared Nodes vCluster*.
