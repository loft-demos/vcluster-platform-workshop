#!/usr/bin/env bash
set -euo pipefail

PLATFORM_NAMESPACE="${PLATFORM_NAMESPACE:-vcluster-platform}"

echo "[verify] checking cluster access..."
kubectl get nodes >/dev/null

echo "[verify] checking platform namespace..."
kubectl get ns "${PLATFORM_NAMESPACE}" >/dev/null

echo "[verify] bootstrap environment is ready."
