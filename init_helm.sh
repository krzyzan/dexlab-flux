#!/bin/bash

set -e

SAVED_CONTEXT=`kubectl config current-context`

for CONTEXT in staging production; do
  kubectl config use-context $CONTEXT
  kubectl -n kube-system create serviceaccount tiller
  kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
  helm init --service-account tiller --upgrade --wait
done

kubectl config use-context $SAVED_CONTEXT
