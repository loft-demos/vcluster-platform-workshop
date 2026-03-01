#!/usr/bin/env bash
set -euo pipefail

PLATFORM_NAMESPACE="${PLATFORM_NAMESPACE:-vcluster-platform}"
RELEASE_NAME="${RELEASE_NAME:-loft}"
UI_LOCAL_PORT="${UI_LOCAL_PORT:-8080}"

echo "[verify] checking cluster access..."
kubectl get nodes >/dev/null

echo "[verify] checking vCluster Platform deployment..."
kubectl -n "${PLATFORM_NAMESPACE}" get deploy "${RELEASE_NAME}" >/dev/null
kubectl -n "${PLATFORM_NAMESPACE}" wait --for=condition=Available "deployment/${RELEASE_NAME}" --timeout=60s >/dev/null

echo "[verify] checking local UI endpoint..."
curl -fsS "http://127.0.0.1:${UI_LOCAL_PORT}" >/dev/null

echo "[verify] environment is ready."
