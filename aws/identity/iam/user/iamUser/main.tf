# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "iam_user_name" {
  description = "Nome do usuário do IAM"
  default     = "iamUserTest"
}

# variable "user_password" {
#   description = "Senha do usuário do IAM"
#   default     = "Senha123!"
# }

variable "policy_name1" {
  description = "Nome da Política de Permissões Criada"
  default     = "policyTest"
}

variable "policy_name2" {
  description = "Nome da Política de Permissões Existente"
  default     = "AmazonS3FullAccess"
}

variable "policy_name3" {
  description = "Nome da Política de Permissões Criada (Inline Policy)"
  default     = "policyTest2"
}



# Executando o código
provider "aws" {
  region = var.region
}

# Criando um usuário do IAM
resource "aws_iam_user" "example" {
  name = var.iam_user_name
}

# Criando um perfil de login
resource "aws_iam_user_login_profile" "example" {
  user                    = aws_iam_user.example.name
  password_reset_required = true
}

# Criando uma chave de acesso
resource "aws_iam_access_key" "example" {
  user = aws_iam_user.example.name
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

# Anexando a política criada ao usuário (Customer Managed)
resource "aws_iam_user_policy_attachment" "example1" {
  user      = aws_iam_user.example.name
  policy_arn = aws_iam_policy.example.arn
}

# Anexando uma política existente ao usuário (AWS Managed)
resource "aws_iam_user_policy_attachment" "example2" {
  user      = aws_iam_user.example.name
  policy_arn = "arn:aws:iam::aws:policy/${var.policy_name2}"
}

# Anexando uma política em linha (Inline Policy = Customer Inline)
resource "aws_iam_user_policy" "example" {
  name       = var.policy_name3
  user       = aws_iam_user.example.name
  policy     = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::seu-bucket/*"
    }
  ]
}
EOF
}



# Outputs
output "user_name" {
  value = aws_iam_user.example.name
}

output "policy_name1" {
  value = aws_iam_policy.example.name
}

output "policy_name2" {
  value = var.policy_name2
}

output "policy_name3" {
  value = aws_iam_user_policy.example.name
}

output "access_key_info" {
  value = {
    access_key_id     = aws_iam_access_key.example.id,
    secret_access_key = aws_iam_access_key.example.secret
  }
  sensitive = true
}

output "iam_user_password" {
  value = aws_iam_user_login_profile.example.password
  sensitive = true
}



# Comandos à executar (Deletar os arquivos após destruição)
# terraform output access_key_info | Out-File -FilePath "G:\Meu Drive\4_PROJ\scripts\aws\.default\secrets\accessKey\keyAccessTest.json" -Append
# terraform output iam_user_password | Out-File -FilePath "G:\Meu Drive\4_PROJ\scripts\aws\.default\secrets\accessKey\iamUserPassword.txt" -Append