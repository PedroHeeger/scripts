# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "hosted_zone_name" {
  description = "Nome da Zona de Hospedagem"
  type        = string
  # default     = "hosted-zone-test1.com.br."
  default = "pedroheeger.dev.br."
}

variable "domain_name" {
  description = "Nome de Domínio"
  type        = string
  # default     = "hosted-zone-test1.com.br"
  default = "pedroheeger.dev.br"
}

variable "hosted_zone_comment" {
  description = "Comentário da Zona de Hospedagem"
  type        = string
  default     = "Hosted Zone Comment Test 1"
}

variable "full_domain_name" {
  description = "Nome de Domínio"
  type        = string
  # default     = "www.hosted-zone-test1.com.br"
  default     = "test.pedroheeger.dev.br"
}

variable "ttl" {
  description = "Tempo em segundos que um registro DNS deve ser armazenado em cache por outros sistemas"
  type        = string
  default     = 300
}




# Executando o código
provider "aws" {
  region = var.region
}

# Criando o certificado ACM
resource "aws_acm_certificate" "example" {
  domain_name       = var.full_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# # Criando a Hosted Zone
# resource "aws_route53_zone" "example" {
#   name              = var.hosted_zone_name
#   comment           = var.hosted_zone_comment
# }

# Extraindo a Hosted Zone
data "aws_route53_zone" "existing" {
  name = var.hosted_zone_name
}

# Criando um registro na Hosted Zone para o domínio com certificado
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
  ttl             = var.ttl
  type            = each.value.type
  zone_id         = aws_route53_zone.example.zone_id
  # zone_id         = data.aws_route53_zone.existing.zone_id
}




# Saída
output "hosted_zone_id" {
  value = aws_route53_zone.example.id
  # value = data.aws_route53_zone.existing.id
}

output "certificate_arn" {
  value = aws_acm_certificate.example.arn
}