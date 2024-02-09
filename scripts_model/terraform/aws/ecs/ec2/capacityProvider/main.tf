# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "roleName" {
  description = "Nome da role"
  default     = "ecsTaskExecutionRole"
}

variable "capacityProviderName" {
  description = "Nome do fornecedor de capacidade"
  default     = "capacityProviderTest1"
}

variable "asgName" {
  description = "Nome do Auto Scaling Group"
  default     = "asgTest1"
}



# Executando o código
provider "aws" {
  region = var.region
}

data "aws_autoscaling_groups" "default" {
  names = [var.asgName]
}

resource "aws_ecs_capacity_provider" "example" {
  name = var.capacityProviderName

  auto_scaling_group_provider {
    auto_scaling_group_arn = data.aws_autoscaling_groups.default[0].arn
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
    managed_termination_protection = "DISABLED"
  }
}

output "capacity_provider_arn" {
  value = aws_ecs_capacity_provider.example.arn
}