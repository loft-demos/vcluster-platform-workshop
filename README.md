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

- A Kubernetes cluster with administrator access  
  > The workshop uses [**vCluster in Docker (`vind`)**](https://www.vcluster.com/docs/vcluster/deploy/control-plane/docker-container/basics), which will be installed during the setup lab and provides the required cluster automatically.

- **Container Runtime (Required for `vind`)**
  - **macOS users: Install [OrbStack](https://orbstack.dev/download) — required and strongly recommended.**  
    OrbStack provides better performance, lower resource usage, and a smoother experience than Docker Desktop for this workshop.
  - Other platforms: Docker Desktop or a compatible Docker Engine runtime

- Minimum **4GB RAM and 4 CPU cores** available to your container runtime
- Egress access from vCluster Platform pods to `https://admin.loft.sh/*` (HTTPS, port 443) for license retrieval and validation
- `helm` installed — **Helm v3.10+ required**  
  See the [Helm Installation Guide](https://helm.sh/docs/intro/install/)
- `kubectl` v1.35.0+ installed — Kubernetes CLI  
  See [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

---

> ⚠️ **Mac users are highly recommended to use OrbStack for this workshop.**  
> The labs are tested primarily against OrbStack. Docker Desktop may work, but it is not the supported path for macOS.

> ℹ️ The vCluster CLI and `vind` will be installed as part of the pre-workshop setup below.

### Pre-Workshop Setup

If you are attending a vCluster Labs-led workshop, complete the following setup before the event.

- [Install vCluster Platform using **vCluster in Docker (vind)**](./labs/install-vcluster-platform-with-vind.md)

## Module 1: vCluster Tenancy Models

Virtual clusters are fully functional Kubernetes clusters, but how you deploy the control plane and worker nodes defines the tenancy model for the virtual cluster.

In this module, you will explore the full spectrum of flexible vCluster tenancy models - [Shared Nodes](https://www.vcluster.com/docs/vcluster/introduction/architecture#shared-nodes), [Dedicated Nodes](https://www.vcluster.com/docs/vcluster/introduction/architecture#dedicated-nodes) and [Private Nodes](https://www.vcluster.com/docs/vcluster/introduction/architecture#private-nodes) - and learn how vCluster Platform enhances, standardizes, and manages them at scale.

### Tenancy Model Labs

These labs are hands-on examples that will explore vCluster tenancy models in the context of vCluster Platform:

- [Shared Nodes Tenancy Model](/labs/tenancy-models/shared-nodes.md)
- [Dedicated Nodes Tenancy Model](/labs/tenancy-models/dedicated-nodes.md)
- [Private Nodes Tenancy Model](/labs/tenancy-models/private-nodes.md)

## Module 2: vCluster Platform GitOps

In this module, you will integrate vCluster Platform into a GitOps workflow.

Coming soon.
