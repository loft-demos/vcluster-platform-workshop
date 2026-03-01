# Deploy Workload

Connect to your vCluster and deploy the sample app:

`vcluster platform connect vcluster shared-nodes-vcluster --project default`{{exec}}
`kubectl apply -f src/podinfo-deploy.yaml`{{exec}}
`kubectl get pods -n demo`{{exec}}

Wait for the `podinfo` pod to be `Running`.
