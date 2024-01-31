# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "lbName" {
  description = "Nome do Application Load Balancer"
  default     = "lbTest1"
}

variable "aZ1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "aZ2" {
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

variable "listenerProtocol" {
  description = "Protocolo do Listener"
  default     = "HTTP"
}

variable "listenerPort" {
  description = "Porta do Listener"
  default     = 80
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_security_group" "default" {
  name        = "default"
  vpc_id      = data.aws_vpcs.default.ids[0]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default.ids[0]]
  }

  filter {
    name   = "availability-zone"
    values = [var.aZ1, var.aZ2]
  }
}

data "aws_subnet" "selected_default_subnet" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# output "subnet_ids" {
#   value = [for s in data.aws_subnet.selected_default_subnet : s.id]
# }


resource "aws_lb" "example" {
  name               = var.lbName
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.default.id]
  subnets            = [for s in data.aws_subnet.selected_default_subnet : s.id]

  enable_deletion_protection = false // Define como true se você deseja proteção contra exclusão
}

resource "aws_lb_target_group" "example" {
  name        = var.tgName
  port        = var.tgPort
  protocol    = var.tgProtocol
  target_type = var.tgType
  protocol_version = var.tgProtocolVersion
  vpc_id      = data.aws_vpcs.default.ids[0]
  
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

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.listenerPort
  protocol          = var.listenerProtocol

  # default_action {
  #   type             = "fixed-response"
  #   fixed_response {
  #     content_type = "text/plain"
  #     status_code  = "200"
  #     message_body = "OK"
  #   }
  # }

  dynamic "default_action" {
    for_each = aws_lb_target_group.example.arn != null ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.example.arn
    }
  }
}