variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "mission-status"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "desired_size" {
  description = "Desired node group size"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum node group size"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum node group size"
  type        = number
  default     = 4
}

variable "instance_types" {
  description = "Node group instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ecr_repository_name" {
  description = "Name for ECR repository"
  type        = string
  default     = "mission-status-api"
}

variable "cluster_version" {
  description = "EKS control plane version"
  type        = string
  default     = "1.31"
}

