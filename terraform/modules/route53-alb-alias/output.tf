output "alb_dns_name" {
  value = data.aws_lb.this.dns_name
}

output "fqdn" {
  value = aws_route53_record.this.fqdn
}
