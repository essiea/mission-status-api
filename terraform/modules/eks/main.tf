module "eks" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v20.24.2"
  version = "20.24.2"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }
}

