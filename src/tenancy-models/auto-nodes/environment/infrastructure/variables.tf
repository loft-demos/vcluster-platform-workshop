# Keep this permissive because vCP may inject different variables depending on version/config.
# If you want to tighten this later, paste the injected vars from the controller logs.
variable "environment" {
  type        = any
  description = "Environment context injected by vCluster Platform (optional)."
  default     = {}
}