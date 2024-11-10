# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "clb_name" {
  description = "Nome do Classic Load Balancer (CLB)"
  type        = string
  default     = "clbTest1"
}

variable "az1" {
  description = "Nome da zona de disponibilidade 1"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Nome da zona de disponibilidade 2"
  type        = string
  default     = "us-east-1b"
}

variable "listener_protocol" {
  description = "Protocolo do Listener"
  type        = string
  default     = "HTTP"
}

variable "listener_port" {
  description = "Porta do Listener"
  type        = number
  default     = 80
}

variable "instance_protocol" {
  description = "Protocolo da Instância"
  type        = string
  default     = "HTTP"
}

variable "instance_port" {
  description = "Porta da Instância"
  type        = number
  default     = 80
}

variable "hc_protocol" {
  description = "Protocolo usado para a verificação de saúde (e.g., HTTP, HTTPS)."
  type        = string
  default     = "HTTP"
}

variable "hc_port" {
  description = "Porta usada para a verificação de saúde."
  type        = number
  default     = 80
}

variable "hc_path" {
  description = "Caminho usado na verificação de saúde."
  type        = string
  default     = "index.html"
}

variable "hc_interval_seconds" {
  description = "Intervalo entre as verificações de saúde em segundos."
  type        = number
  default     = 15
}

variable "unhealthy_threshold" {
  description = "Número de verificações malsucedidas para considerar o recurso não saudável."
  type        = number
  default     = 2
}

variable "healthy_threshold" {
  description = "Número de verificações bem-sucedidas para considerar o recurso saudável."
  type        = number
  default     = 5
}

variable "hc_timeout_seconds" {
  description = "Tempo limite em segundos para cada verificação de saúde."
  type        = number
  default     = 5
}




# Executando o código
provider "aws" {
  region = var.region
}

# Extraindo a VPC
data "aws_vpcs" "default_vpc" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# Extraindo as sub-redes
data "aws_security_group" "default" {
  name        = "default"
  vpc_id      = data.aws_vpcs.default_vpc.ids[0]
}

# Criando o Classic Load Balancer (CLB)
resource "aws_elb" "example" {
  name               = var.clb_name
  availability_zones = [var.az1, var.az2]

  listener {
    instance_port        = var.instance_port
    instance_protocol    = var.instance_protocol
    lb_port              = var.listener_port
    lb_protocol          = var.listener_protocol
  }

  security_groups = [data.aws_security_group.default.id] 

  health_check {
    target               = "${var.hc_protocol}:${var.hc_port}/${var.hc_path}"
    interval             = var.hc_interval_seconds
    unhealthy_threshold  = var.unhealthy_threshold
    healthy_threshold    = var.healthy_threshold
    timeout              = var.hc_timeout_seconds
  }
}