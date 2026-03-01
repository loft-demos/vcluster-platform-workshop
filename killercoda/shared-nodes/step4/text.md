# Verify Host Sync

Disconnect from the virtual cluster so `kubectl` targets the host:

`vcluster disconnect`{{exec}}

Verify synced resources in the host namespace:

`kubectl -n loft-default-v-shared-nodes-vcluster get pods`{{exec}}
`kubectl -n loft-default-v-shared-nodes-vcluster get ingress`{{exec}}

You should see synced `podinfo` resources in that namespace.
