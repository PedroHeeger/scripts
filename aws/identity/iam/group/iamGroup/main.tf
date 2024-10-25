# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "iam_group_name" {
  description = "Nome do grupo do IAM"
  default     = "iamGroupTest"
}

variable "policy_name1" {
  description = "Nome da Política de Permissões Criada"
  default     = "policyTest"
}

variable "policy_name2" {
  description = "Nome da Política de Permissões Existente"
  default     = "AmazonS3FullAccess"
}



# Executando o código
provider "aws" {
  region = var.region
}

# Criando um grupo IAM
resource "aws_iam_group" "example" {
  name = var.iam_group_name
}

# Adicionando o usuário ao grupo
resource "aws_iam_user_group_membership" "example" {
  user  = "iamUserTest"
  groups = [aws_iam_group.example.name]
}

# Criando uma política gerenciada
resource "aws_iam_policy" "example" {
  name        = var.policy_name1
  description = "Permite acesso aos objetos de um bucket do Amazon S3"
  policy      = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::seu-bucket/*"
    }
  ]
}
EOF
}

# Anexando a política criada ao grupo
resource "aws_iam_group_policy_attachment" "example1" {
  group      = aws_iam_group.example.name
  policy_arn = aws_iam_policy.example.arn
}

# Anexando uma política existente ao grupo
resource "aws_iam_group_policy_attachment" "example2" {
  group      = aws_iam_group.example.name
  policy_arn = "arn:aws:iam::aws:policy/${var.policy_name2}"
}



# Saída
output "group_name" {
  value = aws_iam_group.example.name
}

output "policy_name1" {
  value = aws_iam_policy.example.name
}