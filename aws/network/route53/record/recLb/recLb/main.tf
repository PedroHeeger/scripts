# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "hosted_zone_name" {
  description = "Nome da hosted zone no Route 53"
  type        = string
  default     = "pedroheeger.dev.br."
}

variable "domain_name" {
  description = "Nome de domínio associado à hosted zone"
  type        = string
  default     = "pedroheeger.dev.br"
}

variable "resource_record_name" {
  description = "Nome do registro CNAME a ser criado"
  type        = string
  # default     = "ralb.pedroheeger.dev.br"
  default     = "www.pedroheeger.dev.br"
}

variable "elb_name" {
  description = "Nome do Load Balancer (ALB ou CLB)"
  type        = string
  default     = "albTest1"
  # default     = "clbTest1"
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

# Extraindo a hosted zone
data "aws_route53_zone" "example" {
  name = var.hosted_zone_name
}

# Extraindo o load balancer
data "aws_lb" "example" {
  name               = var.elb_name
}

# Criando o registro do load balancer na hosted zone
resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = var.resource_record_name
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.example.dns_name]
}