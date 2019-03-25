#/bin/bash

set -e

SAVED_CONTEXT=`kubectl config current-context`
function finish {
  kubectl config use-context $SAVED_CONTEXT
}
trap finish EXIT

REPO=krzyzan/dexlab-flux

for CONTEXT in staging production; do
  echo $CONTEXT
  kubectl config use-context $CONTEXT
  kubectl apply -f https://raw.githubusercontent.com/weaveworks/flux/master/deploy-helm/flux-helm-release-crd.yaml
  helm upgrade --install --wait flux \
    --set helmOperator.create=true \
    --set helmOperator.createCRD=false \
    --set helmOperator.chartsSyncInterval=1m \
    --set git.pollInterval=1m \
    --set git.url=git@github.com:${REPO} \
    --set git.path="common\,${CONTEXT}" \
    --set git.branch=${CONTEXT} \
    --set git.label=flux-sync-${CONTEXT} \
    --set registry.excludeImage="*metallb*" \
    --namespace flux weaveworks/flux

  sleep 30
  echo "Manually add following deployment key to ${REPO} with write access"
  fluxctl --k8s-fwd-ns=flux identity
  
done
