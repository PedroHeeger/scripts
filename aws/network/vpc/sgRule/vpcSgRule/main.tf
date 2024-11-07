# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Nome da VPC"
  default     = "vpcTest1"
}

variable "sg_name" {
  description = "Nome do Security Group"
  default     = "sgTest1"
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

variable "refer_sg_name" {
  description = "Nome do Security Group de Referência"
  default     = "sgReferTest1"
}

variable "refer_sg_description" {
  description = "Descrição do Security Group de Referência"
  default     = "Security Group de Referencia Test1"
}

variable "refer_sg_tag_name" {
  description = "Nome da tag do Security Group de Referência"
  default     = "sgReferTest1"
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

# # VPC CREATED
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
  name = "default"
}

# # SG CREATED
# resource "aws_security_group" "example" {
# #   count = var.vpc_name != "default" ? 1 : 0

#   name        = var.sg_name
#   description = var.sg_description
#   # vpc_id      = data.aws_vpcs.default.ids[0]              # PARA VPC DEFAULT
#   vpc_id      = data.aws_vpcs.existing.ids[0]           # PARA VPC CREATED

#   tags = {
#     Name = var.sg_tag_name
#   }
# }


# Criando o SG de referência
resource "aws_security_group" "sg_ref" {
#   count = var.vpc_name != "default" ? 1 : 0

  name        = var.refer_sg_name
  description = var.refer_sg_description
  vpc_id      = data.aws_vpcs.default.ids[0]              # PARA VPC DEFAULT
  # vpc_id      = data.aws_vpcs.existing.ids[0]           # PARA VPC CREATED

  tags = {
    Name = var.refer_sg_tag_name
  }
}


# Criando a regra de entrada no SG
resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = data.aws_security_group.default.id       # PARA SG DEFAULT
  # security_group_id = aws_security_group.example.id              # PARA SG CREATED
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = var.protocol
  # cidr_blocks       = [var.cidrIpv4]                             # Faixa de IP
  source_security_group_id = aws_security_group.sg_ref.id      # SG de referência 
}


# Saída
output "sg_id" {
  value = data.aws_security_group.default.id                     # PARA SG DEFAULT
  # value = aws_security_group.example.id                        # PARA SG CREATED
}

output "refer_sg_id" {
  value = aws_security_group.sg_ref.id                        # PARA SG CREATED
}