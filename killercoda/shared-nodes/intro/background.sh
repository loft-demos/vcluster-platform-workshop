#!/usr/bin/env bash
set -euo pipefail

#######################################
# Helpers
#######################################
log() { echo -e "\n==> $*\n"; }

sudo_if_needed() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

VCLUSTER_VERSION="${VCLUSTER_VERSION:-v0.33.0-alpha.0}"

log "Installing vcluster CLI ${VCLUSTER_VERSION}..."
curl -fsSLo vcluster "https://github.com/loft-sh/vcluster/releases/download/${VCLUSTER_VERSION}/vcluster-linux-amd64"
chmod +x vcluster
sudo_if_needed mv vcluster /usr/local/bin/vcluster

# wait fo k8s ready
while ! kubectl get nodes | grep -w "Ready"; do
  echo "WAIT FOR NODES READY"
  sleep 1
done
touch /ks/.k8sfinished

# allow pods to run on controlplane
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-

# mark init finished
touch /ks/.initfinished
