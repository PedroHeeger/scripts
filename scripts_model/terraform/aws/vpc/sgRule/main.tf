# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "port" {
  description = "Número da porta"
  default     = 22
}

variable "protocol" {
  description = "Protocolo"
  default     = "tcp"
}

variable "cidrIpv4" {
  description = "Faixa de IPs"
  default     = "0.0.0.0/0"
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_security_group" "default" {
  name  = "default"
  vpc_id = data.aws_vpcs.default.ids[0]
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = data.aws_security_group.default.id
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = var.protocol
  cidr_blocks       = [var.cidrIpv4]
}


# Saída
output "security_group_id" {
  value = data.aws_security_group.default.id
}