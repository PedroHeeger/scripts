# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Nome da VPC"
#   default     = "default"
  default     = "vpcTest1"
}

variable "cidr_block" {
  description = "CIDR Block da VPC"
  default     = "10.0.0.0/24"
}



# Executando o código
provider "aws" {
  region = var.region
}


resource "aws_vpc" "example" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}


# Saída
output "vpc_id" {
  value = aws_vpc.example.id
}