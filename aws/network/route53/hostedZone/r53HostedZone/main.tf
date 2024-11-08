# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

# variable "hostedZoneName" {
#   description = "Nome da Zona de Hospedagem"
#   default = "hosted-zone-test1.com.br."
# }

# variable "domainName" {
#   description = "Nome de Domínio"
#   default = "hosted-zone-test1.com.br"
# }

# variable "hostedZoneComment" {
#   description = "Comentário da Zona de Hospedagem"
#   default = "hostedZoneCommentTest1"
# }

variable "hostedZoneName" {
  description = "Nome da Zona de Hospedagem"
  default = "pedroheeger.dev.br."
}

variable "domainName" {
  description = "Nome de Domínio"
  default = "pedroheeger.dev.br"
}

variable "hostedZoneComment" {
  description = "Comentário da Zona de Hospedagem"
  default = "hostedZoneCommentTest1"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_route53_zone" "example" {
  name              = var.hostedZoneName
  comment           = var.hostedZoneComment
}


# Saída
output "hosted_zone_id" {
  value = aws_route53_zone.example.id
}