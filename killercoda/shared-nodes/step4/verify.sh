#!/usr/bin/env bash
set -euo pipefail

kubectl -n loft-default-v-shared-nodes-vcluster get pods | grep -q "podinfo"
kubectl -n loft-default-v-shared-nodes-vcluster get ingress podinfo >/dev/null
echo "step4 ok"
