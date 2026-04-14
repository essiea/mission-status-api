#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-mission-status-api}"
APP_NAMESPACE="${APP_NAMESPACE:-mission-status}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
TF_ROOT="${TF_ROOT:-terraform}"
TF_ENV_FILE="${TF_ENV_FILE:-environments/dev/dev.tfvars}"
TF_BACKEND_CONFIG="${TF_BACKEND_CONFIG:-backend-configs/dev.hcl}"
BACKEND_ROOT="${BACKEND_ROOT:-bootstrap/state-backend}"
STATE_BUCKET="${STATE_BUCKET:-mission-status-api-tfstate}"
LBC_RELEASE="${LBC_RELEASE:-aws-load-balancer-controller}"
LBC_NAMESPACE="${LBC_NAMESPACE:-kube-system}"

echo "Starting teardown..."
echo "App: $APP_NAME"
echo "Namespace: $APP_NAMESPACE"
echo "Terraform root: $TF_ROOT"
echo "Backend root: $BACKEND_ROOT"
echo "State bucket: $STATE_BUCKET"

delete_argocd_app() {
  echo
  echo "==> Deleting ArgoCD application (if present)"
  if kubectl get application "$APP_NAME" -n "$ARGOCD_NAMESPACE" >/dev/null 2>&1; then
    kubectl delete application "$APP_NAME" -n "$ARGOCD_NAMESPACE" --wait=true
  else
    echo "ArgoCD application not found, skipping."
  fi
}

cleanup_app_namespace() {
  echo
  echo "==> Cleaning application namespace resources"
  kubectl delete ingress --all -n "$APP_NAMESPACE" --ignore-not-found=true
  kubectl delete svc --all -n "$APP_NAMESPACE" --ignore-not-found=true
  kubectl delete deployment --all -n "$APP_NAMESPACE" --ignore-not-found=true
  kubectl delete replicaset --all -n "$APP_NAMESPACE" --ignore-not-found=true
  kubectl delete pods --all -n "$APP_NAMESPACE" --ignore-not-found=true

  if kubectl get namespace "$APP_NAMESPACE" >/dev/null 2>&1; then
    kubectl delete namespace "$APP_NAMESPACE" --ignore-not-found=true --wait=false || true
  fi
}

uninstall_lbc() {
  echo
  echo "==> Uninstalling AWS Load Balancer Controller (if present)"
  if helm list -n "$LBC_NAMESPACE" | awk '{print $1}' | grep -qx "$LBC_RELEASE"; then
    helm uninstall "$LBC_RELEASE" -n "$LBC_NAMESPACE"
  else
    echo "Load Balancer Controller Helm release not found, skipping."
  fi
}

destroy_main_infra() {
  echo
  echo "==> Destroying main Terraform infrastructure"
  terraform -chdir="$TF_ROOT" init -backend-config="$TF_BACKEND_CONFIG"
  terraform -chdir="$TF_ROOT" destroy -var-file="$TF_ENV_FILE" -auto-approve
}

empty_state_bucket() {
  echo
  echo "==> Emptying backend state bucket"
  if aws s3api head-bucket --bucket "$STATE_BUCKET" >/dev/null 2>&1; then
    "$(dirname "$0")/empty-s3-bucket.sh" "$STATE_BUCKET"
  else
    echo "State bucket not found, skipping."
  fi
}

destroy_backend() {
  echo
  echo "==> Destroying Terraform backend resources"
  terraform -chdir="$BACKEND_ROOT" init
  terraform -chdir="$BACKEND_ROOT" destroy -auto-approve
}

delete_argocd_app
cleanup_app_namespace
uninstall_lbc
destroy_main_infra
empty_state_bucket
destroy_backend

echo
echo "Teardown complete."
