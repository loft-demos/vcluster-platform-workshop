# Shared Nodes: Setup + Lab

This scenario bootstraps:
- required CLIs (`kubectl`, `helm`, `vcluster`)

## 1) Validate bootstrap

`kubectl get nodes`{{exec}}

## 2) Install vCluster Platform (reduced footprint)

Use the vCluster CLI to install vCluster in Docker (vind) with vCluster Platform:

`vcluster create vcp-cluster --driver docker --upgrade --values /assets/vcluster.yaml`{{exec}}

This prints the hosted vCluster Platform URL and bootstrap username/password.

## 3) Open vCluster Platform UI

Run the following command to get you vCluster Platform host domain URL to open in your browser:

```
PLATFORM_NAMESPACE=vcluster-platform

echo "Waiting for vCluster Platform router domain..."

kubectl wait \
  --for=condition=Available \
  deployment/loft \
  -n $PLATFORM_NAMESPACE \
  --timeout=120s

until kubectl -n $PLATFORM_NAMESPACE get secret loft-router-domain >/dev/null 2>&1; do
  sleep 2
done

DOMAIN=$(kubectl get secret loft-router-domain \
  -n $PLATFORM_NAMESPACE \
  -o jsonpath="{.data.domain}" | base64 --decode 2>/dev/null || base64 -D)

echo "Open: https://${DOMAIN}"
```{{exec}}

Open the `https://<random>.loft.host` URL printed by the previous command in a new browser tab and use the provided username/password to log into and register vCluster Platform.

## 4) Configure and Login to vCluster Platform with the vCluster CLI

After logging into vCluster Platform in your browser run the following to get your loft router domain and access key:

```
export VCP_HOST="https://$(kubectl -n vcluster-platform get secret loft-router-domain -o jsonpath='{.data.domain}' | base64 -d)"

export ACCESS_KEY="$(
  kubectl get accesskeys.storage.loft.sh -o json \
  | jq -r '.items
    | map(select(.spec.user=="admin" and .spec.type=="Login"))
    | sort_by(.metadata.creationTimestamp)
    | last
    | .spec.key'
)"

```{{exec}}

If you created an access key in the UI, CLI login is then:

`vcluster platform login "${VCP_HOST}" --access-key "$ACCESS_KEY"`{{exec}}

## 5) Run the Shared Nodes lab flow

For this scenario, focus on:
- creating the Shared Nodes virtual cluster
- deploying a sample workload
- verifying host sync behavior

Skip optional heavy sections if time is limited.

## Notes

- This scenario does not use local port-forward by default.
- This scenario does not install ingress-nginx.
- CNPG is optional and may exceed time/resource limits in free sessions.
