# Architecture Overview

This project demonstrates a secure DevOps delivery path for a containerized Python API on Amazon EKS.

## Flow
1. Developer pushes code to GitLab.
2. GitLab CI runs formatting, linting, testing, SAST, Terraform validation, Checkov, and Trivy.
3. Docker image is built and pushed to ECR.
4. Helm values are updated with the new image tag.
5. ArgoCD detects the Git change and synchronizes the deployment to EKS.
6. The application runs in EKS and is ready for Prometheus, Grafana, and Loki integrations.

## Security Highlights
- Terraform-managed infrastructure
- ECR scan-on-push enabled
- Bandit SAST for Python code
- Checkov for infrastructure-as-code checks
- Trivy for container vulnerability scanning
- Kubernetes liveness and readiness probes

