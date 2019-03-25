#/bin/bash

set -e

REPO=krzyzan/dexlab-flux

for CONTEXT in minikube staging production; do
  kubectl --context $CONTEXT apply -f https://raw.githubusercontent.com/weaveworks/flux/master/deploy-helm/flux-helm-release-crd.yaml
  helm upgrade --install --wait flux weaveworks/flux \
    --kube-context $CONTEXT --namespace flux \
    --set helmOperator.create=true \
    --set helmOperator.createCRD=false \
    --set helmOperator.chartsSyncInterval=1m \
    --set git.pollInterval=1m \
    --set git.url=git@github.com:${REPO} \
    --set git.path="common\,${CONTEXT}" \
    --set git.branch=${CONTEXT} \
    --set git.label=flux-sync-${CONTEXT} \
    --set registry.excludeImage="*metallb*"
done

# Wait for flux to initialize
sleep 30

SAVED_CONTEXT=`kubectl config current-context`
function finish {
  kubectl config use-context $SAVED_CONTEXT
}
trap finish EXIT

for CONTEXT in minikube staging production; do
  kubectl config use-context ${CONTEXT}
  echo "Manually add following ${CONTEXT} deployment key with write access to ${REPO}"
  fluxctl --k8s-fwd-ns=flux identity
done
