#!/bin/bash
set -e
kubectl get secret kube-ca -n kube-system -ojson | jq -r '.data."Certificate"' | base64 -D > kube-ca.pem
kubectl get secrets kube-node -n kube-system -ojson | jq -r '.data."Certificate"' | base64 -D > kube-node.pem
kubectl get secrets kube-node -n kube-system -ojson | jq -r '.data."Key"' | base64 -D > kube-node-key.pem
kubectl create secret generic etcd-client-cert \
  --from-file=kube-ca.pem=./kube-ca.pem \
  --from-file=kube-node.pem=./kube-node.pem \
  --from-file=kube-node-key.pem=./kube-node-key.pem \
  --dry-run -n monitoring -o yaml \
| kubeseal --controller-namespace sealed-secrets --controller-name sealed-secrets --format yaml > sealedsecret.yml
rm kube-ca.pem kube-node.pem kube-node-key.pem
