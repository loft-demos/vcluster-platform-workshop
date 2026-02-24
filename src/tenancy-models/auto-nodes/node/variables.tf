############################
# Required input from vCluster Platform Node Provider
############################

variable "vcluster" {
  description = <<EOT
Object provided by the vCluster Platform Terraform Node Provider.

Expected fields used by this module:
- vcluster.namespace (string)
- vcluster.userData (string)
- vcluster.nodeClaim.apiVersion (string)
- vcluster.nodeClaim.kind (string)
- vcluster.nodeClaim.metadata.name (string)
- vcluster.nodeClaim.metadata.uid (string, optional but recommended for ownerReferences)
EOT

  type = any
}

############################
# Demo/workshop knobs
############################

variable "image" {
  description = "Container image for the pod-node. Prefer a pinned tag or digest for repeatable workshops."
  type        = string
  default     = "ghcr.io/fabiankramm/pod-node:latest"
}

variable "image_pull_policy" {
  description = "Image pull policy for workshop stability."
  type        = string
  default     = "IfNotPresent"
  validation {
    condition     = contains(["Always", "IfNotPresent", "Never"], var.image_pull_policy)
    error_message = "image_pull_policy must be one of: Always, IfNotPresent, Never."
  }
}

variable "termination_grace_period_seconds" {
  description = "How quickly the pod-node terminates when deleted (workshop-friendly defaults to 1)."
  type        = number
  default     = 1
}

variable "priority_class_name" {
  description = "Optional priorityClassName for the pod."
  type        = string
  default     = ""
}

variable "extra_labels" {
  description = "Additional labels to attach to the Secret and Pod."
  type        = map(string)
  default     = {}
}

variable "extra_annotations" {
  description = "Additional annotations to attach to the Pod."
  type        = map(string)
  default     = {}
}

variable "node_selector" {
  description = "Optional nodeSelector to constrain where pod-nodes run."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Optional tolerations list."
  type = list(object({
    key                = optional(string)
    operator           = optional(string)
    value              = optional(string)
    effect             = optional(string)
    toleration_seconds = optional(number)
  }))
  default = []
}

variable "resources" {
  description = "Resource requests/limits for the pod-node container."
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })

  # Conservative defaults for workshops; adjust to your pod-node behavior.
  default = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "2"
      memory = "4Gi"
    }
  }
}