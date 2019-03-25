#!/bin/bash

set -e

for CONTEXT in minikube staging production; do
  kubectl --context $CONTEXT --namespace kube-system create serviceaccount tiller
  kubectl --context $CONTEXT create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
  helm init --kube-context $CONTEXT --service-account tiller --upgrade --wait
done
