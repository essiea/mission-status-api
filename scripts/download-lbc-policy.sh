#!/usr/bin/env bash
set -euo pipefail

DEST="terraform/modules/aws-load-balancer-controller"
mkdir -p "$DEST"

curl -o "$DEST/iam_policy.json" \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json

echo "Downloaded IAM policy to $DEST/iam_policy.json"
