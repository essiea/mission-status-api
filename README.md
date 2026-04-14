# Secure GitOps Platform on Amazon EKS

A production-style personal project that demonstrates DevOps, Platform Engineering, and DevSecOps skills using **Terraform**, **Amazon EKS**, **Docker**, **Helm**, **ArgoCD**, and **GitLab CI/CD** and **GitHub Actions**.

## Why this project is relevant
This project is designed to mirror the exact responsibilities of an AWS / EKS / DevOps role:
- Provision AWS infrastructure with Terraform
- Deploy a containerized Python API to Amazon EKS
- Use GitLab CI/CD or GitHub Actions for build, test, and security gates
- Use Helm and ArgoCD for GitOps delivery
- Add code quality and vulnerability scanning
- Follow secure platform engineering practices
- Structure Terraform cleanly for **dev / stage / prod** deployments

## Architecture

```mermaid
flowchart LR
    Dev[Developer Pushes Code] --> GH[GitHub Repository]

    subgraph GitHub Actions
      GH --> CI[Validate + Build + Scan]
      CI --> AWSPush[Push Image to Amazon ECR]
      CI --> GCPPush[Push Image to Artifact Registry]
      AWSPush --> AWSDeploy[Deploy to EKS with Helm]
      GCPPush --> GCPDeploy[Deploy to GKE with Helm]
    end

    subgraph AWS
      TF1[Terraform] --> VPC[VPC]
      TF1 --> EKS[EKS Cluster]
      TF1 --> ECR[ECR Repository]
      TF1 --> LBC[AWS Load Balancer Controller]
      AWSDeploy --> EKS
      EKS --> ALB[Application Load Balancer]
      ACM[ACM Certificate] --> ALB
      R53[Route 53] --> ALB
      ALB --> AWSApp[mission-status-api]
    end

    subgraph GCP
      TF2[Terraform] --> VPC2[VPC Network]
      TF2 --> GKE[GKE Cluster]
      TF2 --> AR[Artifact Registry]
      GCPDeploy --> GKE
      GKE --> GLB[GKE Ingress / Google Load Balancer]
      MC[ManagedCertificate] --> GLB
      DNS[Cloud DNS or External DNS] --> GLB
      GLB --> GCPApp[mission-status-api]
    end

```text
Developer Commit
      |
      v
GitHub Actions / GitLab CI/CD
  - black / flake8
  - pytest
  - bandit
  - terraform validate
  - checkov
  - docker build
  - trivy
      |
      v
Amazon ECR
      |
      v
Helm values update in Git
      |
      v
ArgoCD sync
      |
      v
Amazon EKS
```

## Repository structure
```text
secure-eks-platform/
├── app/
│   ├── main.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── tests/
├── terraform/
│   ├── backend-configs/
│   │   ├── dev.hcl
│   │   ├── stage.hcl
│   │   └── prod.hcl
│   ├── bootstrap/
│   │   └── state-backend/
│   ├── environments/
│   │   ├── dev/dev.tfvars
│   │   ├── stage/stage.tfvars
│   │   └── prod/prod.tfvars
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       └── ecr/
├── helm/
│   └── mission-status-api/
├── gitops/
│   └── argocd-application.yaml
├── docs/
│   └── architecture.md
├── .gitlab-ci.yml
├── .github/workflows/eks-ci-cd.yml
```

## Terraform backend and state locking
This package now includes Terraform code to create the remote state backend resources:
- **S3 bucket** for Terraform state
- **DynamoDB table** for state locking

### Lock table configuration
- Table name: `terraform-locks` by default
- Partition key: `LockID`
- Partition key type: `String`
- Billing mode: `PAY_PER_REQUEST`

Bootstrap files are located in:

```text
terraform/bootstrap/state-backend/
```

## Multi-environment structure
This project is structured so you can deploy separate **dev**, **stage**, and **prod** environments without duplicating code.

### Backend configs
- `terraform/backend-configs/dev.hcl`
- `terraform/backend-configs/stage.hcl`
- `terraform/backend-configs/prod.hcl`

### Environment variables
- `terraform/environments/dev/dev.tfvars`
- `terraform/environments/stage/stage.tfvars`
- `terraform/environments/prod/prod.tfvars`

This lets you keep:
- one reusable Terraform codebase
- one backend bucket
- one lock table
- separate state file paths per environment
- separate environment-specific sizing and CIDRs

## How to deploy the backend resources
```bash
cd terraform/bootstrap/state-backend
cp terraform.tfvars.example terraform.tfvars
# update the bucket name so it is globally unique
terraform init
terraform apply
```

Then update the backend config files with the created bucket and table names.

## Example environment deployment
### Dev
```bash
cd terraform
terraform init -backend-config=backend-configs/dev.hcl
terraform plan -var-file=environments/dev/dev.tfvars
terraform apply -var-file=environments/dev/dev.tfvars
```

### Stage
```bash
terraform init -reconfigure -backend-config=backend-configs/stage.hcl
terraform plan -var-file=environments/stage/stage.tfvars
terraform apply -var-file=environments/stage/stage.tfvars
```

### Prod
```bash
terraform init -reconfigure -backend-config=backend-configs/prod.hcl
terraform plan -var-file=environments/prod/prod.tfvars
terraform apply -var-file=environments/prod/prod.tfvars
```


## GitHub Actions pipeline
This package now also includes a GitHub Actions workflow at:

```text
.github/workflows/eks-ci-cd.yml
```

The workflow performs:
- **black** and **flake8**
- **pytest**
- **bandit**
- **terraform fmt** and **terraform validate**
- **checkov**
- **helm lint**
- **docker build**
- **trivy image scan**
- push to **Amazon ECR**
- update Helm values for GitOps on `main`

### Recommended GitHub Secrets
- `AWS_ROLE_TO_ASSUME` for GitHub OIDC to AWS
- `GH_PAT` only if branch protection or cross-repo push requires a personal access token

If you prefer, you can replace OIDC with standard repository secrets such as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, but OIDC is the more secure option.

## Application
The sample app is a lightweight FastAPI service with three endpoints:
- `GET /health`
- `GET /status`
- `GET /version`

## Terraform components
Terraform provisions:
- VPC with public and private subnets
- NAT gateway
- EKS cluster
- EKS managed node group
- ECR repository with scan-on-push

## GitLab CI/CD pipeline
The pipeline includes:
- **black** and **flake8** for formatting and linting
- **pytest** for unit tests
- **bandit** for Python security checks
- **terraform fmt** and **terraform validate**
- **checkov** for IaC misconfiguration scanning
- **helm lint** for Helm validation
- **docker build**
- **trivy** for image vulnerability scanning
- Push to **Amazon ECR**
- Automatic Helm values update for GitOps deployment

## Required GitLab CI/CD variables
Set these in GitLab project variables:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `GITLAB_TOKEN`

You may also prefer GitLab OIDC / AWS role assumption instead of long-lived credentials
