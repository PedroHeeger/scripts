# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "iam_role_name" {
  description = "Nome da role"
  default     = "iamRoleTest"
}

variable "principal" {
  description = "Principal"
  default     = "Service"
  # default     = "AWS"
}

variable "principal_name" {
  description = "Nome do Principal"
  default     = "ec2.amazonaws.com"                                    # Service
  # default     = "arn:aws:iam::001727357081:user/iamUserTest"         # User
  # default     = "arn:aws:iam::001727357081:role/iamRoleTest2"        # Role
}

variable "policy_name1" {
  description = "Nome da Política de Permissões Criada"
  default     = "policyTest"
}

variable "policy_name2" {
  description = "Nome da Política de Permissões Existente"
  default     = "AmazonS3FullAccess"
}

variable "instance_profile_name" {
  description = "Nome do perfil de instância"
  default     = "instanceProfileTest"
}



# Executando o código
provider "aws" {
  region = var.region
}

# Criando a role
resource "aws_iam_role" "example" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {"${var.principal}" = var.principal_name},
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Criando uma política gerenciada
resource "aws_iam_policy" "example" {
  name        = var.policy_name1
  description = "Permite acesso aos objetos de todos os buckets do Amazon S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::seu-bucket/*"
      }
    ]
  })
}

# Anexando a política criada a role (Customer Managed)
resource "aws_iam_role_policy_attachment" "example1" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example.arn
}

# Anexando uma política existente a role (AWS Managed)
resource "aws_iam_role_policy_attachment" "example2" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/${var.policy_name2}"
}

# Criando um perfil de instância
resource "aws_iam_instance_profile" "example" {
  name = var.instance_profile_name
  role = aws_iam_role.example.name
}




# Saída
output "role_name" {
  value = aws_iam_role.example.name
}

output "policy_name1" {
  value = aws_iam_policy.example.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.example.name
}