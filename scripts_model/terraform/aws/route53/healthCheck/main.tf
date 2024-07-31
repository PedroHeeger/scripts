# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "hosted_zone_name" {
  description = "Nome da hosted zone no Route 53"
  default     = "pedroheeger.dev.br."
}

variable "health_check_name" {
  description = "Nome da verificação de integridade"
  default     = "healthCheckTest4"
}

variable "ip_address" {
  description = "Endereço de IP verificado"
  default     = "175.184.182.193"
}

variable "port_number" {
  description = "Número da porta que a verificação de integridade será executada"
  default     = 80
}

variable "type_protocol" {
  description = "Tipo de protocolo para verificação de integridade"
  default     = "HTTP"
}

variable "resource_path" {
  description = "Caminho (path) para verificação de integridade"
  default     = "/"
}

variable "request_interval" {
  description = "Intervalo entre as verificações"
  default     = 30
}

variable "failure_threshold" {
  description = "Número de verificações de integridade consecutivas que pode falhar (Limite de falhas)"
  default     = 3
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_route53_zone" "example" {
  name = var.hosted_zone_name
}

# HEALTH CHECK
resource "aws_route53_health_check" "example" {
  ip_address        = var.ip_address
  port              = var.port_number
  type              = var.type_protocol
  resource_path     = var.resource_path
  request_interval  = var.request_interval
  failure_threshold = var.failure_threshold

  tags = {
    Name = var.health_check_name
  }
}