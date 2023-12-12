# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "ID da conta AWS"
  type        = string
  default     = "001727357081"
}

variable "budget_name" {
  description = "Gastos acima de 5.0 dolares"
  type        = string
  default     = "Gastos_acima_de_5.0_dolares"
}

variable "limit_amount" {
  description = "Limite do orçamento em USD"
  type        = number
  default     = 5.0
}

variable "threshold" {
  description = "Limite de alerta em percentagem"
  type        = number
  default     = 50
}

variable "address" {
  description = "Endereço de e-mail para notificação"
  type        = string
  default     = "pedroheeger19@gmail.com"
}


# Executando o código
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 0.0.0"
    }
    nullprovider = {
      source  = "hashicorp/null"
      version = ">= 0.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_budgets_budget" "budget_test" {
  name              = var.budget_name
  budget_type       = "COST"
  limit_amount      = var.limit_amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
}

resource "null_resource" "configure_budget_notification" {
  provisioner "local-exec" {
    command = <<-EOT
    aws budgets create-notification --account-id ${var.account_id} --budget-name ${aws_budgets_budget.budget_test.name} --notification NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=${var.threshold},ThresholdType=PERCENTAGE,NotificationState=ALARM --subscribers SubscriptionType=EMAIL,Address=${var.address}
    EOT
  }

  depends_on = [aws_budgets_budget.budget_test]
}