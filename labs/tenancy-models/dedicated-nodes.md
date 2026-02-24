# Dedicated Nodes Tenancy Model

In the **Dedicated Nodes** tenancy model, the vCluster control plane is deployed as a Pod on the host cluster — just like in the **Shared Nodes** tenancy model. The difference is that tenant workloads are restricted to a specific subset of host nodes.

Workloads are directed to labeled nodes using node selectors or affinity rules, and true compute isolation is achieved by combining node taints with enforced tolerations. This ensures that tenant workloads both target the correct nodes and prevent other host workloads (and other synced vCluster workloads) from running there.

While compute is isolated at the node level, the underlying Kubernetes control plane, CNI, CSI, and other cluster infrastructure components remain shared. The vCluster continues to provide API isolation, separate CRDs, tenant-specific RBAC, and control plane security boundaries.

![Dedicated Nodes Architecture](https://www.vcluster.com/docs/assets/images/dedicated-nodes-66b5934ba465de8cfa30aba0399b2fbd.png)

## Lab Overview

In this lab you will:

- Create a parameterized Virtual Cluster Template
- Use template parameters to define the tenant-specific node label (e.g., tenant-a, team-a)
- Create a Dedicated Nodes virtual cluster from that template
- Deploy a workload and verify node placement

## Lab Exercises

### Create a **Dedicated Nodes**  Virtual Cluster Template

This lab exercise walks you through creating a Virtual Cluster Template. A [Virtual Cluster Template](https://www.vcluster.com/docs/platform/understand/what-are-templates) is a vCluster Platform custom resource that specifies how virtual clusters are provisioned - including control plane settings, synchronization behavior, and metadata. Virtual Cluster Templates are backed by a vCluster Platform `VirtualClusterTemplate` custom resource. So although you can create a Virtual Cluster Template in the vCluster Platform UI you also create them via a Kubernetes manifest.

1. Ensure you are connected to your `vcp-cluster` Standalone vCluster you created in *Install vCluster Platform Using vCluster in Docker (vind)*:

```bash
vcluster connect vcp-cluster --driver docker
```

2. Now apply the `VirtualClusterTemplate` Kubernetes manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/tenancy-models/dedicated-nodes/virtual-cluster-template.yaml
```

3. Navigate to your vCluster Platform, expand **Templates** on the left and then click **Virtual Clusters**.
4. Click on the **Dedicated Nodes** template.
5. Below are the three most important parts of the template and what they do:
   1. Enforce a tenant toleration on every synced Pod.
  
      This ensures every workload Pod created inside the vCluster can tolerate the tenant taint (e.g., tenant=team-a:NoSchedule) on the dedicated nodes.

      **What it enables**

      If you taint a node like:

      ```bash
      kubectl taint node worker-3 tenant=team-a:NoSchedule
      ```

      then only Pods with this toleration can be scheduled there.

      Because this is enforced at the vCluster sync layer, you don’t have to add tolerations to every app manifest.

      ```yaml
      sync:
        toHost:
          pods:
            enforceTolerations:
              - "tenant={{.Values.tenantId }}:NoSchedule"
      ```

   2. Select which host nodes are visible to the vCluster (by tenant label)
  
      This block controls which host nodes are considered “available” to the vCluster. It filters by node labels, using the same tenant parameter.

      ```yaml
      sync:
        fromHost:
          nodes:
            # Do not sync real node information
            enabled: false
            # Select nodes based on the node labels
            selector:
              labels:
                tenant: "{{.Values.tenantId }}"
      ```

      **What it enables**

      The vCluster only “sees” nodes that match tenant=<tenantId>.

   3. Template parameter (validation + UX)

      This parameter is defined at the `VirtualClusterTemplate` `spec` level (vCluster Platform), not inside the `vcluster.yaml`. It drives the templating for both node selection and enforced tolerations.

      ```yaml
      parameters:
        - variable: tenantId
          label: vCluster Tenant ID
          description: Sets the tenant id for selecting dedicated nodes.
          type: string
          required: true
          validation: ^[a-z]+(?:-[a-z]+)*$
      ```

      **What it enables**

      Makes tenantId required when users create a vCluster from the template.

      Enforces a safe format: `team-a` but not `Team A`

### Create a Dedicated Nodes Virtual Cluster with a Virtual Cluster Template

This lab exercise walks you through creating a virtual cluster from the Virtual Cluster Template created in the previous exercise.

1. Click on the **Virtual Clusters** link in the top-left menu under **Default Project**, and then click on the **Create virtual cluster** button.
2. Click the **Select Template** button for the **Dedicated Nodes** template.
3. On the next screen, under **Config Options**:
   - Enter *Dedicated Nodes vCluster* for the **Display Name**.
   - Enter *team-a* for the **vCluster Tenant ID** under **Parameters**.
4. Next, click the **Create virtual cluster** button at the bottom right of the page.
5.  Once your *Dedicated Nodes vCluster* is up an running, click on the **Inspect Resources** button - under and to the right of the **Control Plane Pods Status** - and then click on **Deployments**.
6.  Click the **Create Deployment** button.
7.  Set the `namespace` of the `Deployment` manifest to `default` and click the **Create** button.
8.  Click on **Pods** under **Inspect Resources** and you will see a `pod` pending.
9.  Hover over the **Events** warning for the pending pod and you will see that `pod` cannot be scheduled because:

    *0/3 nodes are available: 3 node(s) didn't match Pod's node affinity/selector. no new claims to deallocate, preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling. (FailedScheduling)*

    Your `vcp-cluster` Standalone vCluster (the vCluster shared host cluster) needs a node with the correct label and taints for the pod to be scheduled.

### Create a Dedicated Node

This lab exercise walks you through creating a worker node for your `vcp-cluster` Standalone vCluster with a label and taint that enforce tenant-specific compute isolation.

1.  Now we will add a `node` to your `vcp-cluster` Standalone vCluster with the following command:

```bash
docker run -d --name vcluster.node.vcp-cluster.worker-3 \
  --hostname worker-3 \
  --privileged \
  --stop-timeout 1 \
  -v vcluster.node.vcp-cluster.worker-3-run:/run \
  -v vcluster.node.vcp-cluster.worker-3-containerd:/var/lib/containerd \
  -v vcluster.node.vcp-cluster.worker-3-kubelet:/var/lib/kubelet \
  -v vcluster.node.vcp-cluster.worker-3-vcluster:/var/lib/vcluster \
  ghcr.io/loft-sh/vm-container
```

2. Next, get the join command for your `vcp-cluster` Standalone vCluster:

```bash
vcluster connect vcp-cluster --driver docker
vcluster token create
```

3. Exec into the `vcluster.node.vcp-cluster.worker-3 container`:

```bash
docker exec -it vcluster.node.vcp-cluster.worker-3 /bin/bash
```

4. Run the join command in the `vcluster.node.vcp-cluster.worker-3 container` and then exit:

```bash
curl -fsSLk "https://<replace-with-your-ip>:8443/node/join?token=<replace-with-your-join-token>" | sh -
exit
```

5. Now we will label and taint the new node:

```bash
kubectl get nodes
kubectl label node worker-3 tenant=team-a
kubectl taint node worker-3 tenant=team-a:NoSchedule
```

6. Return to the **Inspect Resources** view of your *Dedicated Nodes vCluster* and select **Pods** and see that the `pod` is now running.
7. Click on the *More* options **⋮** menu of the `pod` and select **Show Yaml**. Search for `nodeSelector` and `key: tenant` and you will find that the node selector nor the toleration exist on workload `pods` in side the vCluster.
8. Now click on the **loft-default-v-dedicated-nodes-vcluster** link at the top-middle of the vCluster Config page to view the host `namespace` where your *Dedicated Nodes vCluster* control plane `pod` is running and view the Yaml for the `deployment-*` `pod`. Search for `nodeSelector` and `key: tenant` and you will find that the node selector and toleration has been added to the synced `pod`.

## What's Next

Continue with the [Private Nodes Tenancy Model Lab](/labs/tenancy-models/private-nodes.md)
