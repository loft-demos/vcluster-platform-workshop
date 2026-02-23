# Dedicated Nodes Tenancy Model

In the **Dedicated Nodes** tenancy model, the vCluster control plane is still deployed as a `Pod` on the host cluster — just like with the **Shared Nodes** tenancy. However, each vCluster is configured with a Kubernetes `nodeSelector` (or affinity rules) that ensures all tenant workloads are scheduled only to nodes with specific labels. For example, a virtual cluster assigned to `nodegroup=tenant-a` will only run `pods` on `nodes `matching that label.

While compute is scoped to these dedicated `nodes,` all other components—like the CNI, CSI, and underlying Kubernetes host cluster—remain shared. The vCluster itself maintains full API isolation, separate CRDs, tenant-specific RBAC, and control plane security

## Lab Overview

In this lab, you will:
