#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
COMPONENT_NAME=$(jq -r '.name // "cp4d-instance"' gitops-output.json)
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"

if [[ ! -f "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml" ]]; then
  echo "Application values not found - payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
  exit 1
fi

echo "Printing payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
cat "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}"
  sleep 30
fi

count=120
until [[ $count -eq 0 ]]; do
  echo "Pausing for $count seconds to wait for everything to settle down"
  count=$((count - 10))
  sleep 10
done

count=0
until kubectl get ibmcpd ibmcpd-cr -n "${NAMESPACE}" || [[ $count -eq 20 ]]; do
  echo "Waiting for ibmcpd/ibmcpd-cr in ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for ibmcpd/ibmcpd-cr in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

STATUS=$(kubectl get Ibmcpd ibmcpd-cr -n "${NAMESPACE}" -o jsonpath="{.status.controlPlaneStatus}{'\n'}")
count=0
until [[ $STATUS == "Completed" ]] || [[ $count -eq 360 ]]; do
  ELAPSED=$((100*count*15/60))
  echo "ibmcpd/ibmcpd-cr status: ${STATUS}  ($(echo $ELAPSED | sed -e 's/..$/.&/;t' -e 's/.$/.0&/') of 90 minutes elapsed)"
  STATUS=$(kubectl get Ibmcpd ibmcpd-cr -n "${NAMESPACE}" -o jsonpath="{.status.controlPlaneStatus}{'\n'}")
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 360 ]]; then
  echo "Timed out waiting for ibmcpd/ibmcpd-cr to achieve Completed status"
  kubectl get ibmcpd ibmcpd-cr -n "${NAMESPACE}" -o yaml
  exit 1
fi



STATUS=$(kubectl get ZenService lite-cr -n "${NAMESPACE}" -o jsonpath="{.status.zenStatus}{'\n'}")
count=0
until [[ $STATUS == "Completed" ]] || [[ $count -eq 360 ]]; do
  ELAPSED=$((100*count*15/60))
  echo "ZenService/lite-cr status: ${STATUS}  ($(echo $ELAPSED | sed -e 's/..$/.&/;t' -e 's/.$/.0&/') of 90 minutes elapsed)"
  STATUS=$(kubectl get ZenService lite-cr -n "${NAMESPACE}" -o jsonpath="{.status.zenStatus}{'\n'}")
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 360 ]]; then
  echo "Timed out waiting for ZenService/lite-cr to achieve Completed status"
  kubectl get get ZenService lite-cr -n "${NAMESPACE}" -o yaml
  exit 1
fi

kubectl get get ZenService lite-cr -n "${NAMESPACE}" -o yaml


cd ..
rm -rf .testrepo
