#!/usr/bin/env bash
set -euo pipefail

PLATFORM_NAMESPACE="${PLATFORM_NAMESPACE:-vcluster-platform}"
VIND_CLUSTER_NAME="${VIND_CLUSTER_NAME:-vcp-cluster}"

select_cluster_context() {
  local ctx
  ctx="$(kubectl config get-contexts -o name 2>/dev/null | grep -m1 "${VIND_CLUSTER_NAME}" || true)"
  if [ -n "${ctx}" ]; then
    kubectl config use-context "${ctx}" >/dev/null 2>&1 || true
  fi
}

echo "[verify] checking cluster access..."
select_cluster_context
kubectl get nodes >/dev/null

echo "[verify] checking platform namespace..."
kubectl get ns "${PLATFORM_NAMESPACE}" >/dev/null

echo "[verify] bootstrap environment is ready."
