💣 Full Environment Teardown Guide

This document describes how to safely and completely destroy all infrastructure and resources created by this project.

⚠️ Why Teardown Order Matters

This project provisions resources across:

Kubernetes (EKS)
AWS Load Balancers (ALB)
Terraform-managed infrastructure
Versioned S3 backend (state storage)

Improper teardown can result in:

Orphaned ALBs
Stuck ENIs / Security Groups
S3 bucket deletion failures (due to versioning)

This guide ensures a clean, repeatable teardown.

🚀 One-Command Teardown

From the root of the project:

make teardown
🔧 What the Teardown Does

The teardown script executes the following steps in order:

1. Delete ArgoCD Application
kubectl delete application mission-status-api -n argocd

Removes all Kubernetes-managed resources.

2. Clean Application Namespace

Deletes:

Ingress
Services
Deployments
Pods
kubectl delete namespace mission-status
3. Uninstall AWS Load Balancer Controller
helm uninstall aws-load-balancer-controller -n kube-system

Ensures ALBs and AWS-managed resources are released.

4. Destroy Terraform Infrastructure
terraform destroy

Removes:

EKS cluster
VPC
IAM roles
Node groups
ECR repositories
5. Empty Versioned S3 Backend Bucket

Because versioning is enabled, Terraform cannot delete the bucket unless it is empty.

The script:

deletes all object versions
deletes delete markers
removes remaining objects
6. Destroy Terraform Backend
cd bootstrap/state-backend
terraform destroy

Removes:

S3 bucket (state storage)
DynamoDB lock table
KMS keys
🧰 Scripts Used
scripts/teardown.sh

Main orchestration script that executes the teardown steps.

scripts/empty-s3-bucket.sh

Handles cleanup of versioned S3 buckets, including:

object versions
delete markers
remaining objects
⚙️ Configuration (Optional Overrides)

You can override defaults via environment variables:

APP_NAME=mission-status-api \
APP_NAMESPACE=mission-status \
STATE_BUCKET=mission-status-api-tfstate \
make teardown
📦 Prerequisites

Ensure the following tools are installed:

aws
kubectl
helm
terraform
jq

Install jq if missing:

sudo yum install jq -y
# OR
brew install jq
🧠 Troubleshooting
❌ S3 Bucket Not Empty

Run manually:

./scripts/empty-s3-bucket.sh <bucket-name>
❌ Terraform Destroy Fails

Check for leftover AWS resources:

aws elbv2 describe-load-balancers
aws ec2 describe-network-interfaces
❌ Kubernetes Resources Still Exist
kubectl get all -n mission-status
kubectl delete namespace mission-status
🎯 Best Practices
Always delete application resources first
Never delete backend before infrastructure
Use automation (make teardown) instead of manual steps
