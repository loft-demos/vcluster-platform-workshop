#!/usr/bin/env bash
set -euo pipefail

#######################################
# Config (override via env vars)
#######################################
PLATFORM_NAMESPACE="${PLATFORM_NAMESPACE:-vcluster-platform}"

KUBECTL_VERSION="${KUBECTL_VERSION:-stable}"
HELM_VERSION="${HELM_VERSION:-v3.15.4}"
VCLUSTER_VERSION="${VCLUSTER_VERSION:-v0.32.0}"

VIND_CLUSTER_NAME="${VIND_CLUSTER_NAME:-vcp-cluster}"
VIND_NAMESPACE="${VIND_NAMESPACE:-}"

ENABLE_DOCKER_CONTAINERD="${ENABLE_DOCKER_CONTAINERD:-0}"

#######################################
# Helpers
#######################################
log() { echo -e "\n==> $*\n"; }
have() { command -v "$1" >/dev/null 2>&1; }

sudo_if_needed() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

#######################################
# Docker: optional containerd image store
#######################################
enable_docker_containerd_store() {
  if [ "${ENABLE_DOCKER_CONTAINERD}" != "1" ]; then
    log "Skipping Docker containerd image store enablement (ENABLE_DOCKER_CONTAINERD=0)."
    return 0
  fi

  if ! have docker; then
    log "Docker not found; skipping containerd image store enablement."
    return 0
  fi

  log "Best-effort: enable Docker containerd image store..."
  sudo_if_needed mkdir -p /etc/docker

  cat <<'EOF' | sudo_if_needed tee /etc/docker/daemon.json >/dev/null
{
  "features": {
    "containerd-snapshotter": true
  }
}
EOF

  if have systemctl; then
    sudo_if_needed systemctl restart docker || true
  else
    sudo_if_needed service docker restart || true
    sudo_if_needed /etc/init.d/docker restart || true
  fi
}

#######################################
# Install kubectl
#######################################
install_kubectl() {
  if have kubectl; then
    log "kubectl already installed."
    return 0
  fi

  log "Installing kubectl..."
  local ver
  if [ "${KUBECTL_VERSION}" = "stable" ]; then
    ver="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  else
    ver="${KUBECTL_VERSION}"
  fi

  curl -fsSLo kubectl "https://dl.k8s.io/release/${ver}/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo_if_needed mv kubectl /usr/local/bin/kubectl
}

#######################################
# Install helm
#######################################
install_helm() {
  if have helm; then
    log "helm already installed."
    return 0
  fi

  log "Installing helm ${HELM_VERSION}..."
  local tgz="helm-${HELM_VERSION}-linux-amd64.tar.gz"
  curl -fsSLO "https://get.helm.sh/${tgz}"
  tar -xzf "${tgz}"
  sudo_if_needed mv linux-amd64/helm /usr/local/bin/helm
  rm -rf linux-amd64 "${tgz}"
}

#######################################
# Install vcluster CLI
#######################################
install_vcluster() {
  if have vcluster; then
    log "vcluster already installed."
    return 0
  fi

  log "Installing vcluster CLI ${VCLUSTER_VERSION}..."
  curl -fsSLo vcluster "https://github.com/loft-sh/vcluster/releases/download/${VCLUSTER_VERSION}/vcluster-linux-amd64"
  chmod +x vcluster
  sudo_if_needed mv vcluster /usr/local/bin/vcluster
}

#######################################
# Ensure a Kubernetes cluster exists via vind
#######################################
ensure_cluster() {
  log "Checking cluster reachability..."
  if kubectl get nodes >/dev/null 2>&1; then
    log "Cluster already reachable."
    return 0
  fi

  log "Creating vind cluster: ${VIND_CLUSTER_NAME}"
  local extra=()
  if [ -n "${VIND_NAMESPACE}" ]; then
    extra+=(--namespace "${VIND_NAMESPACE}")
  fi

  vcluster create "${VIND_CLUSTER_NAME}" --driver docker "${extra[@]}"
  kubectl get nodes
}

main() {
  log "Bootstrap starting..."
  enable_docker_containerd_store
  install_kubectl
  install_helm
  install_vcluster
  ensure_cluster
  kubectl get ns "${PLATFORM_NAMESPACE}" >/dev/null 2>&1 || kubectl create ns "${PLATFORM_NAMESPACE}"
  mkdir -p /root/lab/assets
  cp -a killercoda/shared-nodes/assets/. /root/lab/assets/ 2>/dev/null || true
  log "Bootstrap complete. Next step in intro: run 'vcluster platform start'."
}

main "$@"
