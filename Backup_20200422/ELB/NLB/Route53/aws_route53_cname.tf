/**
resource "dns_cname_record" "kansas_cname" {
  zone  = "sym-adv.com."
  name  = "Kan-Sym-PRD-DMZ-WebApp-NLB-70fe243fb62ffa6d.elb.us-east-1.amazonaws.com"
  cname = "bcbsks.sym-adv.com."
  ttl   = 300
}
**/

resource "aws_route53_record" "www" {
  zone_id = "Z1H753EIYLU71"
  name    = "bcbsks1.sym-adv.com."
  type    = "CNAME"
  ttl     = "300"
  records = ["Kan-Sym-PRD-DMZ-WebApp-NLB-70fe243fb62ffa6d.elb.us-east-1.amazonaws.com"]
}
