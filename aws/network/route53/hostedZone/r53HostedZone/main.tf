# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "hosted_zone_name" {
  description = "Nome da Zona de Hospedagem"
  default = "hosted-zone-test1.com.br."
  # default = "pedroheeger.dev.br."
}

variable "domain_name" {
  description = "Nome de Domínio"
  default = "hosted-zone-test1.com.br"
  # default = "pedroheeger.dev.br"
}

variable "hosted_zone_comment" {
  description = "Comentário da Zona de Hospedagem"
  default = "hostedZoneCommentTest1"
}



# Executando o código
provider "aws" {
  region = var.region
}

# Criando a Zona de Hospedagem
resource "aws_route53_zone" "example" {
  name              = var.hosted_zone_name
  comment           = var.hosted_zone_comment
}



# Saída
output "hosted_zone_id" {
  value = aws_route53_zone.example.id
}