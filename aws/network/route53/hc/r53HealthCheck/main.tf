# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "hosted_zone_name" {
  description = "Nome da hosted zone no Route 53"
  type        = string
  # default     = "hosted-zone-test1.com.br."
  default     = "pedroheeger.dev.br."
}

variable "health_check_name" {
  description = "Nome da verificação de integridade"
  type        = string
  default     = "healthCheckTest1"
}

variable "ip_address" {
  description = "Endereço de IP verificado"
  type        = string
  default     = "175.184.182.193"
}

variable "port_number" {
  description = "Número da porta que a verificação de integridade será executada"
  type        = number
  default     = 80
}

variable "type_protocol" {
  description = "Tipo de protocolo para verificação de integridade"
  type        = string
  default     = "HTTP"
}

variable "resource_path" {
  description = "Caminho (path) para verificação de integridade"
  type        = string
  default     = "/"
}

variable "request_interval" {
  description = "Intervalo entre as verificações"
  type        = number
  default     = 30
}

variable "failure_threshold" {
  description = "Número de verificações de integridade consecutivas que pode falhar (Limite de falhas)"
  type        = number
  default     = 3
}

variable "tag_health_check" {
  description = "Nome da tag do health check"
  type        = string
  default     = "healthCheckTest1"
}

variable "tag_name_instance" {
  description = "Nome da tag da instância"
  type        = string
  # default     = "ec2Test1"
  default     = "ec2R53Test1"
}




# Executando o código
provider "aws" {
  region = var.region
}

# Extraindo a zona de hospedagem
data "aws_route53_zone" "example" {
  name = var.hosted_zone_name
}

# Obtendo informações da instância existente
data "aws_instances" "example" {
  filter {
    name   = "tag:Name"
    values = [var.tag_name_instance]
  }
}

# Criando o health check
resource "aws_route53_health_check" "example" {
  ip_address        = var.ip_address
  # ip_address        = aws_instances.example.public_ip
  port              = var.port_number
  type              = var.type_protocol
  resource_path     = var.resource_path
  request_interval  = var.request_interval
  failure_threshold = var.failure_threshold

  tags = {
    Name = var.tag_health_check
  }
}