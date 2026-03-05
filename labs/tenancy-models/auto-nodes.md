# Auto Nodes Tenancy Model

In the **Auto Nodes** tenancy model, the vCluster control plane can still deployed as a `Pod` on the host cluster — just like with the Shared Nodes and Dedicated Nodes tenancy models - but it can also be deployed as a Standalone vCluster.

In both cases, **vCluster Platform**** is required to automatically provision and join worker nodes using the Auto Nodes feature.

Auto Nodes allows platform teams to declaratively provision compute on demand. Instead of manually creating infrastructure and joining nodes, you define:
- A NodeProvider – how infrastructure is created
- A NodeType – what size/class of infrastructure to create
- A NodeClaim – a request for compute

When a NodeClaim is created, vCluster Platform provisions the underlying infrastructure and automatically joins it to the cluster.

## How This Workshop Implements Auto Nodes

In this workshop environment, Auto Nodes are implemented as simulated (pseudo) nodes running as privileged pods. These pods bootstrap a kubelet and register themselves as Kubernetes Nodes so that they behave like real worker nodes from the scheduler’s perspective.

They are not cloud VMs, but they accurately demonstrate how:
- Nodes are provisioned on demand
- Requested CPU/memory sizes are enforced
- Workloads schedule to newly created nodes
- Nodes can scale up and down based on NodeClaims

The Terraform configuration used here is intentionally simplified for a local workshop environment. The workflow and APIs are the same ones used for Auto Nodes integrations in AWS, Azure, GCP, or on-prem environments — only the infrastructure backend changes.

⸻

## Use the vCluster Platform Terraform Provider

Auto Nodes integrates with infrastructure through the vCluster Platform Terraform Provider.

This allows you to:
- Reuse existing Terraform modules
- Integrate with cloud-native provisioning workflows
- Maintain infrastructure as code
- Support cloud, on-prem, or hybrid backends

In production environments, the same NodeProvider/NodeType/NodeClaim model can provision:
- EC2 instances
- Azure virtual machines
- GCP compute instances
- Bare metal servers
- KubeVirt VMs
- Or other custom infrastructure targets

In this lab, we use a lightweight backend purely to demonstrate the workflow — the control plane APIs and scaling behavior are identical to real-world deployments.

## Lab Overview

In this lab, you will:

- Create an **Auto Nodes `NodeProvider`** to define how infrastructure is dynamically provisioned.
- Create a virtual cluster using the **Private Nodes** tenancy model and configure a Node Pool that uses your `NodeProvider`.
- Deploy a workload and observe vCluster Platform automatically provision and join a new `node`.
- Deploy a larger workload and watch Auto Nodes provision a bigger node, then automatically reschedule workloads based on the requested compute size.

By the end of this lab, you will understand how vCluster Platform can declaratively provision, scale, and right-size infrastructure based on workload demand — using the same APIs and workflow that apply to real cloud environments like AWS, Azure, and GCP.

## Lab Exercises

### Create an Auto Nodes Virtual Cluster

This lab exercise walks you through creating an Auto Nodes virtual cluster using vCluster Platform. You will observe that `nodes` are automatically provisioned on joined to your vCluster by vCluster Platform.

1. Ensure you are connected to your `vcp-cluster` Standalone vCluster:

```bash
vcluster connect vcp-cluster --driver docker
```
2. Create an **Auto Nodes** `NodeProvider` that works with **vind** by running the following command in your terminal:

```bash
kubectl apply -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/tenancy-models/auto-nodes/node-provider.yaml
```

3. Apply the minimal Auto Nodes `VirtualClusterTemplate`:

```bash
kubectl apply -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/tenancy-models/auto-nodes/virtual-cluster-template.yaml
```

4. In the vCluster Platform UI, go to **Virtual Clusters** in the **Default Project** and click **Create virtual cluster**.
5. Click **Select Template** on the **Auto Nodes** template.
6. Set the **Display Name** to *Auto Nodes vCluster*.
7. Under **Parameters**, set **Auto Nodes Limit** to `1`, `3`, or `5` (use `3` unless you want to test tighter or larger pool limits).
8. Click **Create virtual cluster**.
9. After the vCluster is ready, open its configuration and confirm the template enforced:
   - `privateNodes.enabled: true`
   - `privateNodes.autoNodes[0].provider: pod-auto-nodes`
   - `privateNodes.autoNodes[0].dynamic[0].limits.nodes` matches the selected parameter value (`1`, `3`, or `5`)
   - `networking.podCIDR: 10.64.0.0/16`
   - `networking.serviceCIDR: 10.128.0.0/16`
   - `controlPlane.backingStore.etcd.embedded.enabled: true`

### Deploy Workloads to Trigger Auto Nodes Scaling

This lab exercise uses two deployments to drive Auto Nodes scaling behavior. You will first deploy a medium workload, then a larger workload, and observe how NodeClaims and nodes are provisioned.

1. Connect to your Auto Nodes virtual cluster:

```bash
vcluster connect auto-nodes-vcluster --project default
```

2. Deploy the small workload:

```bash
kubectl apply -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/tenancy-models/auto-nodes/deployment-small.yaml
```

3. Watch scheduling and node provisioning - the small workload should not result in a scale up unless something else was already deployed:

```bash
kubectl get pods -w
kubectl get nodeclaims -w
kubectl get nodes -w
```

4. Verify the small workload is running and placed on an auto-provisioned node:

```bash
kubectl get deploy,pod,node
kubectl describe pod -l app=small-app
```

5. Deploy the large workload:

```bash
kubectl apply -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/tenancy-models/auto-nodes/deployment-large.yaml
```

6. Observe scaling behavior again and confirm an additional/larger node claim is created:

```bash
kubectl get nodeclaims
kubectl get nodes
kubectl describe pod -l app=large-app
```

7. Optional: inspect the generated NodePool limits and current usage:

```bash
kubectl get nodepool node-pool-1 -o yaml
kubectl get nodepool node-pool-1 -o jsonpath='{.status.resources}{"\n"}'
```

8. Cleanup workloads:

```bash
kubectl delete -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/tenancy-models/auto-nodes/deployment-large.yaml
kubectl delete -f https://raw.githubusercontent.com/loft-demos/vcluster-platform-workshop/refs/heads/main/src/tenancy-models/auto-nodes/deployment-med.yaml
```

