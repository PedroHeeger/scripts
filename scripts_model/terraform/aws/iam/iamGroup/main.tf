# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "iamGroupName" {
  description = "Nome do grupo do IAM"
  default     = "iamGroupTest"
}

variable "policyArn" {
  description = "ARN da política"
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# Executando o código
provider "aws" {
  region = var.region
}

# Criar um grupo IAM
resource "aws_iam_group" "example_group" {
  name = var.iamGroupName
}

# Adicionar o usuário ao grupo
resource "aws_iam_user_group_membership" "example_user_group_membership" {
  user  = "iamUserTest"
  groups = [aws_iam_group.example_group.name]
}

# Anexar uma política ao grupo
resource "aws_iam_group_policy_attachment" "example_group_policy_attachment" {
  group      = aws_iam_group.example_group.name
  policy_arn = var.policyArn
}