# vCluster Platform Workshop

The vCluster Platform Workshop provides hands-on exercises that introduce platform engineers, DevOps teams, and cloud architects to building secure, scalable, multi-tenant Kubernetes environments using vCluster Platform. vCluster Platform provides the management layer that platform teams need to operate vCluster at scale.

In this workshop, you will learn how to:

- Deploy and manage virtual clusters using vCluster Platform
- Implement different tenancy models (Shared, Dedicated, and Private Nodes)
- Enable isolation between teams and workloads
- Integrate vCluster Platform into GitOps-driven workflows
- Manage multiple host clusters from a centralized control plane

By the end of the workshop, you will understand how to design and operate production-ready multi-tenant Kubernetes platforms using vCluster and vCluster Platform.

## Getting Started

To complete the labs in this workshop, you will need access to a Kubernetes environment with vCluster Platform installed.

vCluster Platform must be installed into a Kubernetes cluster. The easiest way to get started locally is by using [vCluster-in-Docker (vind)](https://github.com/loft-sh/vind).

vind allows you to run [vCluster Standalone](https://www.vcluster.com/docs/vcluster/deploy/control-plane/binary/) inside container-based VMs, providing a fully functional Kubernetes cluster where you can install and experiment with vCluster Platform.

### Prerequisites

- A Kubernetes cluster with administrator access (**using vind fulfills this prerequisite**)
  - You can verify administrative privileges with: `kubectl auth can-i create clusterrole -A`
- vCluster Platform must be installed into the cluster
- Docker Desktop (or an alternative like [Orbstack](https://orbstack.dev) (recommended for Mac))
- Minimum 2GB RAM and 2 CPU cores available to Docker
- Egress access from vCluster Platform pods to `https://admin.loft.sh/*` (HTTPS, port 443) for license retrieval and validation
- `helm` installed: Helm **v3.10** is required for deploying the platform. Refer to the [Helm Installation Guide](https://helm.sh/docs/intro/install/) if you need to install it
- `kubectl` installed: Kubernetes command-line tool for interacting with the cluster. See [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) for installation instructions

### Pre-Workshop Setup

If you are attending a vCluster Labs-led workshop, complete the following setup before the event.

- [Install vCluster Platform using **vCluster in Docker (vind)**](./labs/install-vcluster-platform-with-vind.md)

## Module 1: vCluster Tenancy Models

Virtual clusters are fully functional Kubernetes clusters, but how you deploy the control plane and worker nodes defines the tenancy model for the virtual cluster.

In this module, you will explore the full spectrum of flexible vCluster tenancy models and learn how vCluster Platform enhances, standardizes, and manages them at scale.

### Tenancy Model Labs

These labs are hands-on examples that will explore vCluster tenancy models in the context of vCluster Platform:

- [Shared Nodes Tenancy Model](/labs/tenancy-models/shared-nodes.md)
- [Dedicated Nodes Tenancy Model](/labs/tenancy-models/dedicated-nodes.md)
- [Private Nodes Tenancy Model](/labs/tenancy-models/private-nodes.md)

## Module 2: vCluster Platform GitOps

In this module, you will integrate vCluster Platform into a GitOps workflow.

Coming soon.
