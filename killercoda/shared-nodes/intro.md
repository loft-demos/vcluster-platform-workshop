# Shared Nodes: Setup + Lab

This scenario bootstraps:
- a `vind` Docker-backed cluster (`vcp-cluster`)
- vCluster Platform (`loft` in `vcluster-platform`)
- local UI port-forward on `http://127.0.0.1:8080`

## 1) Wait for bootstrap completion

```bash
tail -f /tmp/loft-portforward.log
```

In a second terminal, validate readiness:

```bash
bash killercoda/shared-nodes/verify.sh
```

## 2) Open vCluster Platform UI

Use the Killercoda port UI for port `8080` (or open `http://127.0.0.1:8080` if local browser access is available).

## 3) Run the Shared Nodes lab flow

Use the existing workshop lab content:

- `labs/tenancy-models/shared-nodes.md`

For this scenario, focus on:
- creating the Shared Nodes virtual cluster
- deploying a sample workload
- verifying host sync behavior

Skip optional heavy sections if time is limited.

## Notes

- This scenario intentionally does not install ingress-nginx.
- This scenario intentionally does not install CNPG by default.
