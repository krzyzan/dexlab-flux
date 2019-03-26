#!/bin/bash

kubectl create secret generic cloudflare-dns --namespace cert-manager --dry-run --from-literal=api-key=$1 -oyaml | kubeseal --controller-namespace sealed-secrets --controller-name sealed-secrets --format yaml > sealedsecret.yml
