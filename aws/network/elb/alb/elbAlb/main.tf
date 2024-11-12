# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "elb_name" {
  description = "Nome do Application Load Balancer"
  default     = "albTest1"
}

variable "az1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "az2" {
  description = "Nome da zona de disponibilidade 2"
  default     = "us-east-1b"
}

variable "elb_type" {
  description = "Define o tipo de load balancer (exemplo: application, network, etc.)"
  type        = string
  default     = "application"
}

variable "scheme" {
  description = "Define o esquema do load balancer (exemplo: internet-facing, internal)"
  type        = string
  default     = "internet-facing"
}

variable "ip_address_type" {
  description = "Define o tipo de endereço IP para o load balancer (exemplo: ipv4)"
  type        = string
  default     = "ipv4"
}

variable "tg_name" {
  description = "Nome do Target Group"
  default     = "tgTest1"
}

variable "tg_type" {
  description = "Tipo de Target Group"
  default     = "instance"
#   default     = "ip"
}

variable "tg_protocol" {
  description = "Protocolo de Rede"
  default     = "HTTP"
}

variable "tg_protocol_version" {
  description = "Versão do Protocolo de Rede"
  default     = "HTTP1"
}

variable "tg_port" {
  description = "Porta"
  default     = "80"
}

variable "tg_health_check_protocol" {
  description = "Protocolo da verificação de integridade"
  default     = "HTTP"
}

variable "tg_health_check_port" {
  description = "Porta da verificação de integridade"
  default     = "traffic-port"
}

variable "tg_health_check_path" {
  description = "Path da verificação de integridade"
  default     = "/"
}

variable "healthy_threshold" {
  description = "O número de verificações bem-sucedidas necessárias para considerar o recurso saudável."
  type        = number
  default     = 5
}

variable "unhealthy_threshold" {
  description = "O número de verificações malsucedidas necessárias para considerar o recurso não saudável."
  type        = number
  default     = 2
}

variable "hc_timeout_seconds" {
  description = "O tempo limite (em segundos) para cada verificação de saúde."
  type        = number
  default     = 5
}

variable "hc_interval_seconds" {
  description = "O intervalo (em segundos) entre as verificações de saúde."
  type        = number
  default     = 15
}

variable "hc_matcher" {
  description = "O código HTTP ou intervalo de códigos HTTP que indica uma verificação bem-sucedida."
  type        = string
  default     = "200"
}

variable "listener_protocol1" {
  description = "Protocolo do Listener"
  default     = "HTTP"
}

variable "listener_port1" {
  description = "Porta do Listener"
  default     = 80
}

variable "listener_protocol2" {
  description = "Protocolo do Listener"
  default     = "HTTPS"
}

variable "listener_port2" {
  description = "Porta do Listener"
  default     = 443
}

variable "domain_name" {
  description = "Nome de Domínio"
  default = "www.pedroheeger.dev.br"
}

variable "redirect_protocol" {
  description = "Protocolo Redirecionado"
  default = "HTTPS"
}

variable "redirectPort" {
  description = "Porta Redirecionada"
  default = 443
}

variable "listener_rule_name" {
  description = "Nome da Regra do Listener"
  default = "listenerRuleTest1"
}




# Executando o código
provider "aws" {
  region = var.region
}

# Extraindo a VPC padrão
data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# Extraindo o grupo de segurança padrão
data "aws_security_group" "default" {
  name        = "default"
  vpc_id      = data.aws_vpcs.default.ids[0]
}

# Extraindo as sub-redes padrões
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default.ids[0]]
  }

  filter {
    name   = "availability-zone"
    values = [var.az1, var.az2]
  }
}

data "aws_subnet" "selected_default_subnet" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# output "subnet_ids" {
#   value = [for s in data.aws_subnet.selected_default_subnet : s.id]
# }


# Criando o load balancer ALB
resource "aws_lb" "example" {
  name               = var.elb_name
  internal           = false
  load_balancer_type = var.elb_type
  security_groups    = [data.aws_security_group.default.id]
  subnets            = [for s in data.aws_subnet.selected_default_subnet : s.id]

  enable_deletion_protection = false // Define como true se você deseja proteção contra exclusão
}


# Criando o target group
resource "aws_lb_target_group" "example" {
  name        = var.tg_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = var.tg_type
  protocol_version = var.tg_protocol_version
  vpc_id      = data.aws_vpcs.default.ids[0]
  
  health_check {
    enabled             = true
    path                = var.tg_health_check_path
    port                = var.tg_health_check_port
    protocol            = var.tg_health_check_protocol
    timeout             = var.hc_timeout_seconds
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.hc_interval_seconds
    matcher             = var.hc_matcher
  }
}


# Criando um listener HTTP
resource "aws_lb_listener" "example_1" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.listener_port1
  protocol          = var.listener_protocol1

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


# Extraindo a ARN do certificado do domínio
data "aws_acm_certificate" "example" {
  domain       = var.domain_name
  statuses = ["ISSUED"]
}


# Criando um listener HTTPS
resource "aws_lb_listener" "example_2" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.listener_port2
  protocol          = var.listener_protocol2
  certificate_arn   = data.aws_acm_certificate.example.arn

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


# Criando uma regra de redirecionamento no listener do HTTP
# Redirecionamento da porta 80 (HTTP) para a porta 443 (HTTPS)
resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.example_1.arn
  priority     = 1

  action {
    type = "redirect"
    redirect {
      protocol      = var.redirect_protocol
      port          = var.redirectPort
      status_code   = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  tags = {
    Name = var.listener_rule_name
  }
}