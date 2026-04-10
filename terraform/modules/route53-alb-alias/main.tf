data "aws_route53_zone" "this" {
  name         = var.hosted_zone_name
  private_zone = false
}

data "aws_lb" "this" {
  name = var.alb_name
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = data.aws_lb.this.dns_name
    zone_id                = data.aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
