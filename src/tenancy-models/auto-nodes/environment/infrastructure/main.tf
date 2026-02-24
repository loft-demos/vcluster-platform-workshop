terraform {
  required_version = ">= 1.3.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}

# This is intentionally a no-op environment module for workshop/demo use.
# vCluster Platform sometimes validates an environment module even if it isn't strictly required.

resource "null_resource" "noop" {}