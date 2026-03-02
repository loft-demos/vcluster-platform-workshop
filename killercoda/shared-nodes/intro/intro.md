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

Set and persist `VCP_HOST` from the installed platform domain:

`export VCP_HOST="https://$(kubectl -n vcluster-platform get secret loft-router-domain -o jsonpath='{.data.domain}' | base64 -d)" && echo "export VCP_HOST=${VCP_HOST}" >> ~/.bashrc && echo "${VCP_HOST}"`{{exec}}

If you created an access key in the UI, CLI login is then:

`vcluster platform login "${VCP_HOST}" --access-key "$ACCESS_KEY"`{{exec}}

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
