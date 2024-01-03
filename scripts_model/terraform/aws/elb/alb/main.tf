# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "lbName" {
  description = "Nome do Application Load Balancer"
  default     = "lbTest1"
}

variable "availabilityZone1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "availabilityZone2" {
  description = "Nome da zona de disponibilidade 2"
  default     = "us-east-1b"
}

variable "tgName" {
  description = "Nome do Target Group"
  default     = "tgTest1"
}

variable "tgType" {
  description = "Tipo de Target Group"
  default     = "instance"
#   default     = "ip"
}

variable "tgProtocol" {
  description = "Protocolo de Rede"
  default     = "HTTP"
}

variable "tgProtocolVersion" {
  description = "Versão do Protocolo de Rede"
  default     = "HTTP1"
}

variable "tgPort" {
  description = "Porta"
  default     = "80"
}

variable "tgHealthCheckProtocol" {
  description = "Protocolo da verificação de integridade"
  default     = "HTTP"
}

variable "tgHealthCheckPort" {
  description = "Porta da verificação de integridade"
  default     = "traffic-port"
}

variable "tgHealthCheckPath" {
  description = "Path da verificação de integridade"
  default     = "/"
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

data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default_vpc.ids[0]]
  }

  filter {
    name   = "availability-zone"
    values = [var.availabilityZone1, var.availabilityZone2]
  }
}

data "aws_subnet" "selected_default_subnet" {
  for_each = toset(data.aws_subnets.default_subnet.ids)
  id       = each.value
}

# output "subnet_ids" {
#   value = [for s in data.aws_subnet.selected_default_subnet : s.id]
# }

# resource "aws_security_group" "lb_sg" {
#   name        = "lb_sg"
#   description = "Security group for Load Balancer"
# }

resource "aws_lb" "lbTest1" {
  name               = var.lbName
  internal           = false
  load_balancer_type = "application"
  # security_groups    = [aws_default_vpc.default.security_group_ids]
  subnets            = [for s in data.aws_subnet.selected_default_subnet : s.id]

  enable_deletion_protection = false // Define como true se você deseja proteção contra exclusão
}

resource "aws_lb_target_group" "tgTest1" {
  name        = var.tgName
  port        = var.tgPort
  protocol    = var.tgProtocol
  target_type = var.tgType
  protocol_version = var.tgProtocolVersion
  vpc_id      = data.aws_vpcs.default_vpc.ids[0]
  
  health_check {
    enabled             = true
    interval            = 15
    path                = var.tgHealthCheckPath
    port                = var.tgHealthCheckPort
    protocol            = var.tgHealthCheckProtocol
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "listenerTest1" {
  load_balancer_arn = aws_lb.lbTest1.arn
  port              = 80
  protocol          = "HTTP"

  # default_action {
  #   type             = "fixed-response"
  #   fixed_response {
  #     content_type = "text/plain"
  #     status_code  = "200"
  #     message_body = "OK"
  #   }
  # }

  dynamic "default_action" {
    for_each = aws_lb_target_group.tgTest1.arn != null ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tgTest1.arn
    }
  }
}