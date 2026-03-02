# Shared Nodes: Setup + Lab

This scenario bootstraps:
- required CLIs (`kubectl`, `helm`, `vcluster`)

## 1) Validate bootstrap

`kubectl get nodes`{{exec}}
`kubectl get ns vcluster-platform`{{exec}}

## 2) Install vCluster Platform (reduced footprint)

Use the preloaded local values file:

`vcluster platform start --no-login --values /assets/vcp-values.yaml`{{exec}}

This prints the hosted vCluster Platform URL and bootstrap username/password.

## 3) Open vCluster Platform UI

Open the `https://<random>.loft.host` URL printed by the previous command in a new browser tab.

## 4) Run the Shared Nodes lab flow

For this scenario, focus on:
- creating the Shared Nodes virtual cluster
- deploying a sample workload
- verifying host sync behavior

Skip optional heavy sections if time is limited.

## Notes

- This scenario does not use local port-forward by default.
- This scenario does not install ingress-nginx.
- CNPG is optional and may exceed time/resource limits in free sessions.
