output "certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}

output "fqdn" {
  value = aws_route53_record.app_alias.fqdn
}
