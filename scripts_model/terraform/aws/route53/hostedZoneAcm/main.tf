# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "hostedZoneName" {
  description = "Nome da Zona de Hospedagem"
  default = "hosted-zone-test1.com.br."
}

variable "domainName" {
  description = "Nome de Domínio"
  default = "hosted-zone-test1.com.br"
}

variable "hostedZoneComment" {
  description = "Comentário da Zona de Hospedagem"
  default = "hostedZoneCommentTest1"
}

variable "fullDomainName" {
  description = "Nome de Domínio"
  default = "www.hosted-zone-test1.com.br"
}



# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_acm_certificate" "example" {
  domain_name       = var.fullDomainName
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "example" {
  name              = var.hostedZoneName
  comment           = var.hostedZoneComment
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.example.zone_id
}




# Saída
output "hosted_zone_id" {
  value = aws_route53_zone.example.id
}