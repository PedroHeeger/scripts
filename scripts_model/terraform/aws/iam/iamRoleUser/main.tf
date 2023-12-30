# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "roleName" {
  description = "Nome da role"
  default     = "roleUserTest"
}

variable "policyName" {
  description = "Nome da policy"
  default     = "policyTest"
}

variable "iamUserName" {
  description = "Nome do usuário do IAM"
  default     = "iamUserTest"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_iam_role" "example_role" {
  name = var.roleName

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",       
        Principal = {AWS = "arn:aws:iam::001727357081:user/${var.iamUserName}"},
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "example_policy" {
  name        = var.policyName
  description = "Exemplo de política criada no Terraform"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_role_policy_attachment_1" {
  policy_arn = aws_iam_policy.example_policy.arn
  role       = aws_iam_role.example_role.name
}

resource "aws_iam_role_policy_attachment" "example_role_policy_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.example_role.name
}


# Saída
output "role_arn" {
  value = aws_iam_role.example_role.arn
}