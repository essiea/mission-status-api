# ☁️ GCP Deployment Guide (GKE)

This guide walks through deploying the application to Google Kubernetes Engine using Terraform and Helm.

---

## 📦 Prerequisites

* gcloud CLI installed and authenticated
* Docker installed
* Terraform installed
* Helm installed

---

## 🚀 Quick Start (Recommended)

### Full Deployment

```bash
make gcp-all
```

---

## 🔧 Manual Deployment (Step-by-Step)

### 1. Provision Infrastructure

```bash
cd gcp/terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

---

### 2. Connect to GKE

```bash
gcloud container clusters get-credentials mission-status-gke \
  --zone us-east1-c \
  --project mission-status-api
```

---

### 3. Build and Push Image

```bash
gcloud auth configure-docker us-east1-docker.pkg.dev

docker build -t us-east1-docker.pkg.dev/<PROJECT_ID>/mission-status/mission-status-api:latest ./app

docker push us-east1-docker.pkg.dev/<PROJECT_ID>/mission-status/mission-status-api:latest
```

---

### 4. Deploy Application

```bash
helm upgrade --install mission-status-api ./helm/mission-status-api \
  -n mission-status \
  --create-namespace \
  -f helm/mission-status-api/values-gcp.yaml
```

---

### 5. Enable HTTPS

```bash
kubectl apply -f gcp/k8s/managed-cert.yaml
kubectl apply -f gcp/k8s/ingress-gke.yaml
```

---

### 6. Verify Deployment

```bash
kubectl get pods -n mission-status
kubectl get ingress -n mission-status
kubectl describe managedcertificate mission-status-cert -n mission-status
```

---

## 🧹 Teardown

```bash
make gcp-teardown
```

---

## ⚠️ Notes

* Ensure DNS for your domain points to the GKE ingress IP
* Certificate provisioning may take several minutes

