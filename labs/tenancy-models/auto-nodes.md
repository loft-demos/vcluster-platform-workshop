# Auto Nodes Tenancy Model

In the **Auto Nodes** tenancy model, the vCluster control plane can still deployed as a `Pod` on the host cluster — just like with the Shared Nodes and Dedicated Nodes tenancy models - but it can also be deployed as a Standalone vCluster.

In both cases, **vCluster Platform**** is required to automatically provision and join worker nodes using the Auto Nodes feature.

In both cases, vCluster Platform is required to automatically provision and join worker nodes using the Auto Nodes feature.

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

1. Navigate to your vCluster Platform domain in your browser and click on the **Virtual Clusters** link in the top-left menu under view of the **Default Project**, and then click on the **Create virtual cluster** button.
2. Next, click **Deploy with vCluster Platform** and then click the **Continue without template** button (we will explore templates later in this workshop).
3. On the next screen, under **Config Options**:
   - Enter *Private Nodes vCluster* for the **Virtual Cluster Name**
   - For the **Tenancy Model** select **Private Nodes**
   - Under **Backing Store Type**, select *Embedded Etcd*


