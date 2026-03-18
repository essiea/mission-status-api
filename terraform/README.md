# Terraform layout

This folder is split into two concerns:

1. `bootstrap/state-backend/` creates the shared S3 bucket and DynamoDB lock table used by Terraform state.
2. The root `terraform/` folder deploys the EKS platform itself.

## Multi-environment backend structure

Use a separate backend config file per environment:

- `backend-configs/dev.hcl`
- `backend-configs/stage.hcl`
- `backend-configs/prod.hcl`

Use a separate `.tfvars` file per environment:

- `environments/dev/dev.tfvars`
- `environments/stage/stage.tfvars`
- `environments/prod/prod.tfvars`

This keeps the code reusable while cleanly separating state and environment-specific values.

## Step 1: Bootstrap the remote backend

```bash
cd terraform/bootstrap/state-backend
cp terraform.tfvars.example terraform.tfvars
# update bucket name and tags
terraform init
terraform plan
terraform apply
```

After apply, copy the output values into each file under `terraform/backend-configs/`.

## Step 2: Deploy dev / stage / prod

### Dev
```bash
cd terraform
terraform init -backend-config=backend-configs/dev.hcl
terraform plan -var-file=environments/dev/dev.tfvars
terraform apply -var-file=environments/dev/dev.tfvars
```

### Stage
```bash
cd terraform
terraform init -reconfigure -backend-config=backend-configs/stage.hcl
terraform plan -var-file=environments/stage/stage.tfvars
terraform apply -var-file=environments/stage/stage.tfvars
```

### Prod
```bash
cd terraform
terraform init -reconfigure -backend-config=backend-configs/prod.hcl
terraform plan -var-file=environments/prod/prod.tfvars
terraform apply -var-file=environments/prod/prod.tfvars
```

## Recommended pattern

- One shared S3 bucket for Terraform state.
- One shared DynamoDB table for locking.
- Separate `key` path per environment.
- Separate `.tfvars` per environment.
- Use `-reconfigure` when switching environments locally.

## Example state layout

```text
s3://my-terraform-state-bucket/
  secure-eks-platform/dev/terraform.tfstate
  secure-eks-platform/stage/terraform.tfstate
  secure-eks-platform/prod/terraform.tfstate
```

## DynamoDB lock table requirements

- Partition key: `LockID`
- Partition key type: `String`
- No sort key required
- Billing mode: `PAY_PER_REQUEST`

