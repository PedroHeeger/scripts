# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "sg_name" {
  description = "Nome do Security Group"
  default     = "sgTest1"
}

variable "vpc_name" {
  description = "Nome da VPC"
  default     = "vpcTest1"
}

variable "sg_description" {
  description = "Descrição do Security Group"
  default     = "Security Group Test1"
}

variable "sg_tag_name" {
  description = "Nome da tag do Security Group"
  default     = "sgTest1"
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

# VPC DEFAULT
data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# VPC CREATED
# data "aws_vpcs" "existing" {
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name]
#   }
# }


# SG DEFAULT
data "aws_security_group" "default" {
  vpc_id = data.aws_vpcs.default.ids[0]                   # PARA VPC DEFAULT
#   vpc_id = data.aws_vpcs.existing.ids[0]                    # PARA VPC CREATED
}

# # SG CREATED
# resource "aws_security_group" "example" {
# #   count = var.vpc_name != "default" ? 1 : 0

#   name        = var.sg_name
#   description = var.sg_description
#   vpc_id      = data.aws_vpcs.default.ids[0]              # PARA VPC DEFAULT
# #   vpc_id      = data.aws_vpcs.existing.ids[0]           # PARA VPC CREATED

#   tags = {
#     Name = var.sg_tag_name
#   }
# }


# RULE
resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = data.aws_security_group.default.id       # PARA SG DEFAULT
#   security_group_id = aws_security_group.example.id              # PARA SG CREATED
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = var.protocol
  cidr_blocks       = [var.cidrIpv4]
}


# Saída
output "sg_id" {
  value = data.aws_security_group.default.id
#   value = aws_security_group.example.id
}