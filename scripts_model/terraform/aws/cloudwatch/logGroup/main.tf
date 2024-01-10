# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "logGroupName" {
  description = "Nome do grupo de log do Amazon CloudWatch"
  default     = "logGroupTest1"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_cloudwatch_log_group" "exemplo_log_group" {
  name = var.logGroupName

  retention_in_days = 30  # Define a retenção em dias para os logs, ajuste conforme necessário
}