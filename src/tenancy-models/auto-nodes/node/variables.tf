############################
# Demo/workshop knobs
############################

variable "image" {
  description = "Container image for the pod-node."
  type        = string
  default     = "ghcr.io/loft-demos/pod-node:0.1.2"
}

variable "image_pull_policy" {
  description = "Always | IfNotPresent | Never"
  type        = string
  default     = "IfNotPresent"
  validation {
    condition     = contains(["Always", "IfNotPresent", "Never"], var.image_pull_policy)
    error_message = "image_pull_policy must be one of: Always, IfNotPresent, Never."
  }
}

variable "termination_grace_period_seconds" {
  description = "Workshop-friendly fast termination."
  type        = number
  default     = 1
}

variable "extra_labels" {
  description = "Extra labels for Pod and Secret."
  type        = map(string)
  default     = {}
}

variable "extra_annotations" {
  description = "Extra annotations for Pod."
  type        = map(string)
  default     = {}
}

variable "node_selector" {
  description = "Optional nodeSelector."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Optional tolerations list."
  type = list(object({
    key      = optional(string)
    operator = optional(string)
    value    = optional(string)
    effect   = optional(string)
  }))
  default = []
}

# Fallback if NodeClaim doesn't provide cpu/memory
variable "resources" {
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "2"
      memory = "4Gi"
    }
  }
}