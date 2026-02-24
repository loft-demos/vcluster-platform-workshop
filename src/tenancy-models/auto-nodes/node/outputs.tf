output "pod_name" {
  value     = kubernetes_pod_v1.pod_node.metadata[0].name
  sensitive = false
}

output "pod_namespace" {
  value     = kubernetes_pod_v1.pod_node.metadata[0].namespace
  sensitive = false
}

output "secret_name" {
  value       = kubernetes_secret_v1.node.metadata[0].name
  description = "Name of the seed secret. Marked sensitive to satisfy OpenTofu's sensitivity checks."
  sensitive   = true
}