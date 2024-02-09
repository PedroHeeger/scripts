# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "roleName" {
  description = "Nome da role"
  default     = "ecs-ec2InstanceRole"
}

variable "policyName" {
  description = "Nome da policy"
  default     = "AmazonECS_FullAccess"
}

variable "serviceName" {
  description = "Nome do serviço (principal)"
  default     = "ec2.amazonaws.com"
}

variable "instanceProfileName" {
  description = "Nome do perfil de instância"
  default     = "instanceProfileTest"
}



# Executando o código
provider "aws" {
  region = var.region
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
  name        = var.policyName
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = data.aws_iam_policy.example.arn
  role       = aws_iam_role.example.name
}

# INSTANCE PROFILE
resource "aws_iam_instance_profile" "example" {
  name = var.instanceProfileName
  role = var.roleName
}