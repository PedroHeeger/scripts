# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "hosted_zone_name" {
  description = "Nome da hosted zone no Route 53"
  default     = "hosted-zone-test1.com.br."
}

variable "domain_name" {
  description = "Nome de domínio associado à hosted zone"
  default     = "hosted-zone-test1.com.br"
}

variable "resource_record_name" {
  description = "Nome do registro CNAME a ser criado"
  default     = "recordNameLbTest1"
}

variable "alb_name" {
  description = "Nome do Application Load Balancer"
  default     = "albTest1"
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_route53_zone" "example" {
  name = var.hosted_zone_name
}

data "aws_lb" "example" {
  name               = var.alb_name
}

# RECORD
resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = var.resource_record_name
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_lb.alb.dns_name]
}