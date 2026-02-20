# vCluster Platform Workshop

The vCluster Platform Workshop provides hands-on exercises that introduce platform engineers, DevOps teams, and cloud architects to building secure, scalable, multi-tenant Kubernetes environments using vCluster Platform.

## Prerequisites

- vCluster Platform must be installed into a Kubernetes cluster:
  - Administrator access to a Kubernetes cluster: See Accessing Clusters with kubectl for more information. Your current kube-context must have administrative privileges, which you can verify with `kubectl auth can-i create clusterrole -A`
    - Resources: Minimum 2GB RAM and 2 CPU cores available to Docker
  - A Kubernetes cluster vind (vCluster in Docker) is recommended and vind requires Docker Desktop (or an alternative like Orbstack (recommended for Mac))
  - Allow egress traffic from vCluster Platform pods to https://admin.loft.sh/* (HTTPS, port 443) to enable license retrieval and validation.

## Labs

These labs are hands-on examples that will show how vCluster Platform

- [Install vCluster Platform with **vind**](./labs/install-vcluster-platform-with-vind.md)
- Explore vCluster Tenancy Models
  - Create a Shared Node vCluster
  - Create a Dedicated Node vCluster
  - Create a Private Node vCluster
- Virtual Cluster Templates
