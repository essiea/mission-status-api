output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "app_certificate_arn" {
  value = module.acm_route53.certificate_arn
}

