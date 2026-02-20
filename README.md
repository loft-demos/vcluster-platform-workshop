# vCluster Platform Workshop

The vCluster Platform Workshop provides hands-on exercises that introduce platform engineers, DevOps teams, and cloud architects to building secure, scalable, multi-tenant Kubernetes environments using vCluster Platform.

## Getting Started

In order to complete the labs in this workshop you will need to have a vCluster Platform Kubernetes environment. vCluster Platform must be installed in a Kubernetes cluster and luckily [vCluster-in-Docker (vind)]() makes this easy to setup on your own personal computer running Docker. vind allows running vCluster Standalone in container based VMs, providing a fully functional Kubernetes cluster to install vCluster Platform.

### Prerequisites

- vCluster Platform must be installed into a Kubernetes cluster (using vind fulfills this prerequisite):
  - Administrator access to a Kubernetes cluster: See Accessing Clusters with kubectl for more information. Your current kube-context must have administrative privileges, which you can verify with `kubectl auth can-i create clusterrole -A`
- vind requires Docker Desktop (or an alternative like Orbstack (recommended for Mac))
- Resources: Minimum 2GB RAM and 2 CPU cores available to Docker
- Allow egress traffic from vCluster Platform pods to https://admin.loft.sh/* (HTTPS, port 443) to enable license retrieval and validation.

### Pre-Workshop Setup

If you are attending a vCluster Labs led vCluster Platform workshop then these setup steps should be completed before the start of the workshop event.

- [Install vCluster Platform with **vind**](./labs/install-vcluster-platform-with-vind.md)

## Module 1: vCluster Tenancy Models

Virtual clusters are fully functional Kubernetes clusters, but how you deploy the control plane and worker nodes defines the tenancy model for the virtual cluster. These labs will provide hands-on examples where you will learn the vCluster configuration and capabilities for these tenancy models.

### Tenancy Model Labs

These labs are hands-on examples that will explore vCluster tenancy models with vCluster Platform:

- Create a Shared Node vCluster
- Create a Dedicated Node vCluster
- Create a Private Node vCluster

### vCluster Platform Labs

- vCluster Platform Projects
- Virtual Cluster Templates
- Connected Host Clusters

## Module 2: vCluster Platform GitOps
