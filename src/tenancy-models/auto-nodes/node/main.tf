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

  test_prop = try(var.vcluster.nodeClaim.spec.properties["test"], null)
  kubernetes_version = try(var.vcluster.kubeVersion, "v1.35.0")
  debug_k8s_version = try(var.vcluster.kubeVersion, "missing")
  debug_vcluster_keys = join(",", sort(keys(var.vcluster)))
  debug_instance_keys = join(",", sort(keys(try(var.vcluster.instance, {}))))
  debug_properties_keys = join(",", sort(keys(try(var.vcluster.properties, {}))))
  pre_pull_runcmd = <<-EOT
runcmd:
  - ctr -n k8s.io images pull registry.k8s.io/pause:3.10
  - ctr -n k8s.io images pull registry.k8s.io/kube-proxy:${local.kubernetes_version}
EOT
  user_data_with_prepull = length(split("runcmd:\n", var.vcluster.userData)) > 1 ? replace(
    var.vcluster.userData,
    "runcmd:\n",
    "${local.pre_pull_runcmd}\n"
  ) : "${trimspace(var.vcluster.userData)}\n${local.pre_pull_runcmd}"

  common_labels = merge(
    {
      "app.kubernetes.io/name"     = "pod-node"
      "app.kubernetes.io/part-of"  = "vcluster-auto-nodes"
      "vcluster.loft.sh/nodeclaim" = local.nodeclaim_name
    },
    var.extra_labels,
    local.test_prop != null ? { "test" = tostring(local.test_prop) } : {}
  )

  node_cpu = tostring(var.vcluster.nodeType.spec.resources.cpu)
  node_mem = tostring(var.vcluster.nodeType.spec.resources.memory)
  node_pods = tostring(var.vcluster.nodeType.spec.resources.pods)

  # Workshop-friendly: Guaranteed QoS (requests == limits)
  req_cpu = local.node_cpu
  req_mem = local.node_mem
  lim_cpu = local.node_cpu
  lim_mem = local.node_mem
}

############################
# Secret
############################
resource "kubernetes_secret_v1" "node" {
  metadata {
    name      = "${local.nodeclaim_name}-pod"
    namespace = "pod-nodes"
    labels    = local.common_labels
  }

  type = "Opaque"

  data = {
    "user-data" = local.user_data_with_prepull
    "meta-data" = "{}"
  }
}

############################
# Pod
############################
resource "kubernetes_pod_v1" "pod_node" {
  metadata {
    name      = local.nodeclaim_name
    namespace = local.vcluster_ns
    labels    = local.common_labels

    annotations = merge(var.extra_annotations, {
      "debug.loft.sh/k8s-version"  = local.debug_k8s_version
      "debug.loft.sh/vcluster-keys" = local.debug_vcluster_keys
      "debug.loft.sh/instance-keys" = local.debug_instance_keys
      "debug.loft.sh/properties-keys" = local.debug_properties_keys
    })
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

      env {
        name  = "PODNODE_CPU"
        value = local.node_cpu
      }
      env {
        name  = "PODNODE_MEMORY"
        value = local.node_mem
      }
      env {
        name  = "PODNODE_PODS"
        value = local.node_pods
      }
      env {
        name  = "DEBUG_K8S_VERSION"
        value = local.debug_k8s_version
      }
      env {
        name  = "DEBUG_VCLUSTER_KEYS"
        value = local.debug_vcluster_keys
      }
      env {
        name  = "DEBUG_INSTANCE_KEYS"
        value = local.debug_instance_keys
      }
      env {
        name  = "DEBUG_PROPERTIES_KEYS"
        value = local.debug_properties_keys
      }

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

      volume_mount {
        name       = "run"
        mount_path = "/run"
      }

      volume_mount {
        name       = "var-containerd"
        mount_path = "/var/lib/containerd"
      }

      volume_mount {
        name       = "var-kubelet"
        mount_path = "/var/lib/kubelet"
      }

      volume_mount {
        name       = "var-vcluster"
        mount_path = "/var/lib/vcluster"
      }

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

        items {
          key  = "user-data"
          path = "user-data"
        }

        items {
          key  = "meta-data"
          path = "meta-data"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}
