#!/usr/bin/env bash
set -euo pipefail

kubectl get ns demo >/dev/null
kubectl -n demo get deploy podinfo >/dev/null
kubectl -n demo get pods -l app=podinfo | grep -q "Running"
echo "step3 ok"
