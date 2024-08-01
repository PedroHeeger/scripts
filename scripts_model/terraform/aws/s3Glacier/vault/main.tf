# Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vault_name" {
  description = "Nome do Cofre"
  default = "vaultTest2"
}

variable "account_id" {
  description = "ID da conta da AWS"
  default = "-"
}



# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_glacier_vault" "example" {
  name = var.vault_name

  tags = {
    Name = var.vault_name
  }
}