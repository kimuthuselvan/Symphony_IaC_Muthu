# pull in the dns zone
data "aws_route53_zone" "my_hosted_zone" {
  name         = var.dns_hosted_zone
}


# Create health check for internal application

resource "aws_route53_health_check" "albhealthcheck" {
  fqdn              = aws_lb.app_public.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "Primary-${var.dns_hosted_zone}"
  }
}

resource "aws_route53_health_check" "s3healthcheck" {
  fqdn              = "${var.dns_prefix}.${var.dns_hosted_zone}.s3-website-${var.region_name}.amazonaws.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "Secondary-${var.dns_hosted_zone}"
  }
}



# Create A-records for main page with health checks

resource "aws_route53_record" "main" {
   zone_id          = data.aws_route53_zone.my_hosted_zone.zone_id
   name             = var.dns_prefix
   type             = "A"
   depends_on       = [aws_route53_health_check.albhealthcheck]
   health_check_id = aws_route53_health_check.albhealthcheck.id
   failover_routing_policy {
       type = "PRIMARY"
   }
   set_identifier = "${var.dns_prefix}-Primary"
   alias {
    name                   = aws_lb.app_public.dns_name
    zone_id                = aws_lb.app_public.zone_id
    evaluate_target_health = true
  }
} 


resource "aws_route53_record" "main-standby" {
   zone_id          = data.aws_route53_zone.my_hosted_zone.zone_id
   name             = var.dns_prefix
   type             = "A"
   depends_on       = [aws_route53_health_check.s3healthcheck]
   health_check_id = aws_route53_health_check.s3healthcheck.id
   failover_routing_policy {
       type = "SECONDARY"
   }
   set_identifier = "${var.dns_prefix}-Secondary"
   alias {
    name                   = aws_s3_bucket.site_bucket.website_domain
    zone_id                = aws_s3_bucket.site_bucket.hosted_zone_id
    evaluate_target_health = true
  }
}