# Dedicated Nodes Tenancy Model

In the **Dedicated Nodes** tenancy model, the vCluster control plane is still deployed as a `Pod` on the host cluster — just like with the **Shared Nodes** tenancy. However, each vCluster is configured with a Kubernetes `nodeSelector` (or affinity rules) that ensures all tenant workloads are scheduled only to nodes with specific labels. For example, a virtual cluster assigned to `nodegroup=tenant-a` will only run `pods` on `nodes `matching that label.

While compute is scoped to these dedicated `nodes,` all other components—like the CNI, CSI, and underlying Kubernetes host cluster—remain shared. The vCluster itself maintains full API isolation, separate CRDs, tenant-specific RBAC, and control plane security

## Lab Overview

In this lab you will:

- Create a parameterized Virtual Cluster Template
- Use template parameters to define the tenant-specific node label (e.g., tenant-a, team-a)
- Create a Dedicated Nodes virtual cluster from that template
- Deploy a workload and verify node placement

## Lab Exercises

### Create a **Dedicated Nodes**  Virtual Cluster Template

This lab exercise walks you through creating a Virtual Cluster Template. A Virtual Cluster Templates is a vCluster Platform custom resource that specifies how virtual clusters are provisioned - including control plane settings, synchronization behavior, and metadata.

1. 
