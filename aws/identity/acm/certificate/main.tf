# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

# variable "hosted_zone_name" {
#   description = "Nome da Zona de Hospedagem"
#   default = "hosted-zone-test1.com.br."
# }

# variable "domain_name" {
#   description = "Nome de Domínio"
#   default = "hosted-zone-test1.com.br"
# }

variable "hosted_zone_name" {
  description = "Nome da Zona de Hospedagem"
  default = "pedroheeger.dev.br."
}

variable "domain_name" {
  description = "Nome de Domínio"
  default = "pedroheeger.dev.br"
}




# Executando o código
provider "aws" {
  region = var.region
}

# Criando o certificado
resource "aws_acm_certificate" "example" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Extraindo a Hosted Zone
data "aws_route53_zone" "existing" {
  name = var.hosted_zone_name
}

# Criando um record na Hosted Zone para o domínio com o certificado criado
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
  zone_id         = data.aws_route53_zone.existing.zone_id
}

# resource "aws_acm_certificate_validation" "example" {
#   certificate_arn         = aws_acm_certificate.example.arn
#   validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
# }


# Saída
output "certificate_arn" {
  value = aws_acm_certificate.example.arn
}