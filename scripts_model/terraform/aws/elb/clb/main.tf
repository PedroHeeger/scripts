# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "clbName" {
  description = "Nome do Classic Load Balancer (CLB)"
  default     = "clbTest1"
}

variable "aZ1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "aZ2" {
  description = "Nome da zona de disponibilidade 2"
  default     = "us-east-1b"
}

variable "listenerProtocol" {
  description = "Protocolo do Listener"
  default     = "HTTP"
}

variable "listenerPort" {
  description = "Porta do Listener"
  default     = 80
}

variable "instanceProtocol" {
  description = "Protocolo da Instância"
  default     = "HTTP"
}

variable "instancePort" {
  description = "Porta da Instância"
  default     = 80
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_vpcs" "default_vpc" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_security_group" "default" {
  name        = "default"
  vpc_id      = data.aws_vpcs.default_vpc.ids[0]
}

resource "aws_elb" "example" {
  name               = var.clbName
  availability_zones = [var.aZ1, var.aZ2]

  listener {
    instance_port        = var.instancePort
    instance_protocol    = var.instanceProtocol
    lb_port              = var.listenerPort
    lb_protocol          = var.listenerProtocol
  }

  security_groups = [data.aws_security_group.default.id] 

  health_check {
    target               = "${var.listenerProtocol}:${var.listenerPort}/index.html"
    interval             = 15
    unhealthy_threshold  = 2
    healthy_threshold    = 5
    timeout              = 5
  }
}