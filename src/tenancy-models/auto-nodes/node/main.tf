terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
  }
}

provider "kubernetes" {}

locals {
  nodeclaim_name = var.vcluster.nodeClaim.metadata.name
  vcluster_ns    = var.vcluster.namespace

  common_labels = merge(
    {
      "app.kubernetes.io/name"     = "pod-node"
      "app.kubernetes.io/part-of"  = "vcluster-auto-nodes"
      "vcluster.loft.sh/nodeclaim" = local.nodeclaim_name
    },
    var.extra_labels
  )

  # Try common places a NodeClaim might carry resources; fall back to defaults.
  node_cpu = coalesce(
    try(var.vcluster.nodeClaim.spec.resources.cpu, null),
    try(var.vcluster.nodeClaim.spec.resources.requests.cpu, null),
    try(var.vcluster.nodeClaim.spec.nodeType.resources.cpu, null),
    var.resources.limits.cpu
  )

  node_mem = coalesce(
    try(var.vcluster.nodeClaim.spec.resources.memory, null),
    try(var.vcluster.nodeClaim.spec.resources.requests.memory, null),
    try(var.vcluster.nodeClaim.spec.nodeType.resources.memory, null),
    var.resources.limits.memory
  )

  # Workshop-friendly: Guaranteed QoS (requests == limits)
  req_cpu = local.node_cpu
  req_mem = local.node_mem
  lim_cpu = local.node_cpu
  lim_mem = local.node_mem

  owner_uid = try(var.vcluster.nodeClaim.metadata.uid, null)
}

############################
# Secret
############################
resource "kubernetes_secret_v1" "node" {
  metadata {
    name      = "${local.nodeclaim_name}-pod"
    namespace = local.vcluster_ns
    labels    = local.common_labels

    dynamic "owner_references" {
      for_each = local.owner_uid == null ? [] : [1]
      content {
        api_version = var.vcluster.nodeClaim.apiVersion
        kind        = var.vcluster.nodeClaim.kind
        name        = var.vcluster.nodeClaim.metadata.name
        uid         = local.owner_uid
        controller  = true
      }
    }
  }

  type = "Opaque"

  data = {
    "user-data" = var.vcluster.userData
    "meta-data" = "{}"
  }
}

############################
# Pod
############################
resource "kubernetes_pod_v1" "pod_node" {
  metadata {
    name        = local.nodeclaim_name
    namespace   = local.vcluster_ns
    labels      = local.common_labels
    annotations = var.extra_annotations

    dynamic "owner_references" {
      for_each = local.owner_uid == null ? [] : [1]
      content {
        api_version = var.vcluster.nodeClaim.apiVersion
        kind        = var.vcluster.nodeClaim.kind
        name        = var.vcluster.nodeClaim.metadata.name
        uid         = local.owner_uid
        controller  = true
      }
    }
  }

  spec {
    termination_grace_period_seconds = var.termination_grace_period_seconds

    # Empty map is fine; avoid null here.
    node_selector = var.node_selector

    dynamic "toleration" {
      for_each = var.tolerations
      content {
        key      = try(toleration.value.key, null)
        operator = try(toleration.value.operator, null)
        value    = try(toleration.value.value, null)
        effect   = try(toleration.value.effect, null)
      }
    }

    container {
      name              = "pod-node"
      image             = var.image
      image_pull_policy = var.image_pull_policy

      security_context {
        privileged = true
      }

      resources {
        requests = {
          cpu    = local.req_cpu
          memory = local.req_mem
        }
        limits = {
          cpu    = local.lim_cpu
          memory = local.lim_mem
        }
      }

      volume_mount { name = "run"            mount_path = "/run" }
      volume_mount { name = "var-containerd" mount_path = "/var/lib/containerd" }
      volume_mount { name = "var-kubelet"    mount_path = "/var/lib/kubelet" }
      volume_mount { name = "var-vcluster"   mount_path = "/var/lib/vcluster" }
      volume_mount {
        name       = "user-data"
        mount_path = "/var/lib/cloud/seed/nocloud"
        read_only  = true
      }
    }

    volume {
      name = "run"
      empty_dir {
      }
    }

    volume {
      name = "var-containerd"
      empty_dir {
      }
    }

    volume {
      name = "var-kubelet"
      empty_dir {
      }
    }

    volume {
      name = "var-vcluster"
      empty_dir {
      }
    }

    volume {
      name = "user-data"
      secret {
        secret_name = kubernetes_secret_v1.node.metadata[0].name
        items { key = "user-data" path = "user-data" }
        items { key = "meta-data" path = "meta-data" }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}