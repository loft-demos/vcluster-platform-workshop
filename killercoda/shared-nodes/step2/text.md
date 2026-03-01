# Create Shared Nodes vCluster

1. Open the hosted vCluster Platform URL printed by `vcluster platform start`.
2. Go to **Virtual Clusters** in **Default Project**.
3. Click **Create virtual cluster**.
4. Click **Deploy with vCluster Platform** and **Continue without template**.
5. Set:
   - **Display Name**: `Shared Nodes vCluster`
   - **Backing Store Type**: `Embedded Etcd`
6. Click **Create virtual cluster** and wait for it to become Ready.

You can monitor from CLI:

`kubectl get ns | grep loft-default-v-shared-nodes-vcluster`{{exec}}
`kubectl -n loft-default-v-shared-nodes-vcluster get pods`{{exec}}
