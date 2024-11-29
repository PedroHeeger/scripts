# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "log_group_name" {
  description = "Nome do grupo de log do Amazon CloudWatch"
  type        = string
  default     = "logGroupTest1"
}



# Executando o código
provider "aws" {
  region = var.region
}

# Criando um grupo de log
resource "aws_cloudwatch_log_group" "exemplo_log_group" {
  name = var.log_group_name

  retention_in_days = 30  # Define a retenção em dias para os logs, ajuste conforme necessário
}