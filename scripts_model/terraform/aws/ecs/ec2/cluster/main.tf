variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "clusterName" {
  description = "Nome da cluster"
  default     = "clusterEC2Test1"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "example" {
  name = var.clusterName
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}