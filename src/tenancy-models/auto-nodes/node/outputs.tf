output "pod_name" {
  value = kubernetes_pod_v1.pod_node.metadata[0].name
}

output "pod_namespace" {
  value = kubernetes_pod_v1.pod_node.metadata[0].namespace
}

output "secret_name" {
  value = kubernetes_secret_v1.node.metadata[0].name
}