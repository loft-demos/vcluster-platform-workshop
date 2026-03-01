# Validate Bootstrap

Confirm the environment is ready:

`kubectl get nodes`{{exec}}
`kubectl get ns vcluster-platform`{{exec}}

If verification fails, inspect setup logs:

`kubectl get pods -A`{{exec}}

Open vCluster Platform:

- Run the install command from the intro page:
- `vcluster platform start --values /tmp/vcp-values.yaml`{{exec}}
