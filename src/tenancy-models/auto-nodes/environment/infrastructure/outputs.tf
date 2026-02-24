# Some implementations expect *some* outputs to exist.
# These are harmless and can be ignored by your node module.

output "environment_id" {
  value = "incluster-noop"
}

output "credentials" {
  value       = ""
  description = "No cloud credentials required for in-cluster pod nodes."
  sensitive   = true
}