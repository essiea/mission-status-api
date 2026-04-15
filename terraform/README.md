# 🏗️ Terraform Infrastructure Guide

This directory contains Terraform code for provisioning AWS infrastructure and managing state.

---

## 📁 Structure

```bash
terraform/
├── bootstrap/state-backend/
├── backend-configs/
├── environments/
├── modules/
└── main.tf
```

---

## 🔐 Remote State Backend

The backend consists of:

* S3 bucket (state storage)
* DynamoDB table (state locking)
* KMS encryption

---

## 🚀 Step 1: Bootstrap Backend

```bash
cd terraform/bootstrap/state-backend
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

---

## 🌍 Step 2: Deploy Environments

### Dev

```bash
cd terraform
terraform init -backend-config=backend-configs/dev.hcl
terraform apply -var-file=environments/dev/dev.tfvars
```

---

### Stage

```bash
terraform init -reconfigure -backend-config=backend-configs/stage.hcl
terraform apply -var-file=environments/stage/stage.tfvars
```

---

### Prod

```bash
terraform init -reconfigure -backend-config=backend-configs/prod.hcl
terraform apply -var-file=environments/prod/prod.tfvars
```

---

## 🧠 Best Practices

* Separate backend configs per environment
* Separate tfvars per environment
* Use `-reconfigure` when switching environments
* Store secrets securely (not in tfvars)

---

## 📦 State Layout Example

```text
s3://bucket/
  dev/terraform.tfstate
  stage/terraform.tfstate
  prod/terraform.tfstate
```

---

## 🔐 DynamoDB Requirements

* Partition key: `LockID`
* Type: String
* Billing: PAY_PER_REQUEST

