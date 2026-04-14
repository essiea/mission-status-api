# GCP Deployment Guide

## Deploy infra
cd gcp/terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

## Connect to GKE
gcloud container clusters get-credentials mission-status-gke --region us-east1

## Build and push image
gcloud auth configure-docker us-east1-docker.pkg.dev
docker build -t us-east1-docker.pkg.dev/YOUR_PROJECT_ID/mission-status/mission-status-api:latest .
docker push us-east1-docker.pkg.dev/YOUR_PROJECT_ID/mission-status/mission-status-api:latest

## Deploy app
helm upgrade --install mission-status-api ./helm/mission-status-api \
  -n mission-status \
  --create-namespace \
  -f helm/mission-status-api/values-gcp.yaml

## Enable HTTPS
kubectl apply -f gcp/k8s/managed-cert.yaml
kubectl apply -f gcp/k8s/ingress-gke.yaml

## Check ingress
kubectl get ingress -n mission-status

# GCP Deployment Guide

## Provision infrastructure
make gcp-infra

## Connect kubectl to GKE
make gcp-connect

## Build and push image
make gcp-build
make gcp-push

## Deploy app and ingress
make gcp-deploy
make gcp-ingress

## Full one-shot workflow
make gcp-all

## Destroy GCP environment
make gcp-teardown
