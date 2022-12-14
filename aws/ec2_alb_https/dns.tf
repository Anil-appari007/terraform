###########################################
#######   Certificate Manager
###########################################
resource "aws_acm_certificate" "cert_for_https" {
  domain_name       = var.dns_name
  validation_method = "DNS"
}

###########################################
#######   Create DNS record for domain verification
###########################################
resource "aws_route53_record" "dns_record_for_cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert_for_https.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id = var.dns_zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert_for_https.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_record_for_cert : record.fqdn]
}