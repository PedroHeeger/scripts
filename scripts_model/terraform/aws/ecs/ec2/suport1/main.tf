# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "roleName" {
  description = "Nome da role"
  default     = "ecsTaskExecutionRole"
}

variable "policyName" {
  description = "Nome da policy"
  default     = "AmazonECSTaskExecutionRolePolicy"
}

variable "serviceName" {
  description = "Nome do serviço (principal)"
  default     = "ecs-tasks.amazonaws.com"
}

variable "logGroupName" {
  description = "Nome do grupo de log do Amazon CloudWatch"
  default     = "/aws/ecs/ec2/taskEc2Test1"
}

variable "port" {
  description = "Número da porta"
  default     = 8080
}

variable "protocol" {
  description = "Protocolo"
  default     = "tcp"
}

variable "cidrIpv4" {
  description = "Faixa de IPs"
  default     = "0.0.0.0/0"
}



# Executando o código
provider "aws" {
  region = var.region
}

# VPC DEFAULT
data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# SG DEFAULT
data "aws_security_group" "default" {
  vpc_id = data.aws_vpcs.default.ids[0]                   # PARA VPC DEFAULT
#   vpc_id = data.aws_vpcs.existing.ids[0]                    # PARA VPC CREATED
  name = "default"
}

# RULE
resource "aws_security_group_rule" "example" {
  security_group_id = data.aws_security_group.default.id       # PARA SG DEFAULT
#   security_group_id = aws_security_group.example.id              # PARA SG CREATED
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = var.protocol
  cidr_blocks       = [var.cidrIpv4]
}


# ROLE
resource "aws_iam_role" "example" {
  name = var.roleName

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = var.serviceName
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# POLICY
data "aws_iam_policy" "example" {
  name = var.policyName
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = data.aws_iam_policy.example.arn
  role       = aws_iam_role.example.name
}


# LOG GROUP
resource "aws_cloudwatch_log_group" "example" {
  name = var.logGroupName

  retention_in_days = 30  # Define a retenção em dias para os logs, ajuste conforme necessário
}