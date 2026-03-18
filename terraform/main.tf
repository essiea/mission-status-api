data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source               = "./modules/vpc"
  name                 = "${var.project_name}-${var.environment}"
  vpc_cidr             = var.vpc_cidr
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "${var.ecr_repository_name}-${var.environment}"
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "${var.project_name}-${var.environment}-eks"
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnet_ids
  vpc_id          = module.vpc.vpc_id
  desired_size    = var.desired_size
  min_size        = var.min_size
  max_size        = var.max_size
  instance_types  = var.instance_types
}

