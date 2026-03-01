#!/usr/bin/env bash
set -euo pipefail

kubectl get ns loft-default-v-shared-nodes-vcluster >/dev/null
kubectl -n loft-default-v-shared-nodes-vcluster get pods >/dev/null
echo "step2 ok"
