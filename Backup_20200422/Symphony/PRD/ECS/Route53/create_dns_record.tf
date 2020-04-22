provider "aws" {
  region     = var.region_name
}

# pull in the dns zone
data "aws_route53_zone" "my_hosted_zone" {
  name         = var.dns_hosted_zone
}

data "aws_lb" "my_nlb" {
  name         = var.nlb_name
}

data "aws_alb" "maintenance_alb" {
  name         = var.alb_name_maintenance_page
}



# Create health check for internal application

resource "aws_route53_health_check" "albhealthcheck" {
  fqdn              = data.aws_lb.my_nlb.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "Primary-${var.dns_prefix}-${var.dns_hosted_zone}"
  }
}

resource "aws_route53_health_check" "maintenancepagehealthcheck" {
  fqdn              = data.aws_alb.maintenance_alb.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "Secondary-${var.dns_prefix}-${var.dns_hosted_zone}"
  }
}

# Create A-records for main page with health checks

resource "aws_route53_record" "main" {
   count            = var.maintenance_time == "yes" ? 0 : 1
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
    name                   = data.aws_lb.my_nlb.dns_name
    zone_id                = data.aws_lb.my_nlb.zone_id
    evaluate_target_health = true
  }
} 


resource "aws_route53_record" "main-standby" {
   zone_id          = data.aws_route53_zone.my_hosted_zone.zone_id
   name             = var.dns_prefix
   type             = "A"
   depends_on       = [aws_route53_health_check.maintenancepagehealthcheck]
   health_check_id = aws_route53_health_check.maintenancepagehealthcheck.id
   failover_routing_policy {
       type = "SECONDARY"
   }
   set_identifier = "${var.dns_prefix}-Secondary"
   alias {
    name                   = data.aws_alb.maintenance_alb.dns_name
    zone_id                = data.aws_alb.maintenance_alb.zone_id
    evaluate_target_health = true
  }
}




resource "aws_route53_record" "f5_main" {
   count            = var.maintenance_time == "yes" ? 0 : 1
   zone_id          = data.aws_route53_zone.my_hosted_zone.zone_id
   name             = var.f5_prefix
   type             = "A"
   depends_on       = [aws_route53_health_check.albhealthcheck]
   health_check_id = aws_route53_health_check.albhealthcheck.id
   failover_routing_policy {
       type = "PRIMARY"
   }
   set_identifier = "${var.f5_prefix}-Primary"
   alias {
    name                   = data.aws_lb.my_nlb.dns_name
    zone_id                = data.aws_lb.my_nlb.zone_id
    evaluate_target_health = true
  }
 
}


resource "aws_route53_record" "f5-main-standby" {
   zone_id          = data.aws_route53_zone.my_hosted_zone.zone_id
   name             = var.f5_prefix
   type             = "A"
   depends_on       = [aws_route53_health_check.maintenancepagehealthcheck]
   health_check_id  = aws_route53_health_check.maintenancepagehealthcheck.id
   failover_routing_policy {
       type = "SECONDARY"
   }
   set_identifier = "${var.f5_prefix}-Secondary"
   alias {
    name                   = data.aws_alb.maintenance_alb.dns_name
    zone_id                = data.aws_alb.maintenance_alb.zone_id
    evaluate_target_health = true
  }
}
