# Create Private Nodes vCluster

Confirm the environment is ready:

`kubectl get nodes`{{exec}}
`kubectl get ns vcluster-platform`{{exec}}

If verification fails, inspect setup logs:

`kubectl get pods -A`{{exec}}

```yaml
privateNodes:
  enabled: true
  vpn:
    enabled: true
networking:
  podCIDR: 10.64.0.0/16
  serviceCIDR: 10.128.0.0/16
controlPlane:
  backingStore:
    etcd:
      embedded:
        enabled: true
  statefulSet:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 256Mi
```
