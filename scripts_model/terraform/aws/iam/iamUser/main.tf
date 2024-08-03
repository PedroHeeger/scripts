# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "iamUserName" {
  description = "Nome do usuário do IAM"
  default     = "iamUserTest"
}

# variable "userPassword" {
#   description = "Senha do usuário do IAM"
#   default     = "Senha123!"
# }

variable "policyName" {
  description = "Nome da Política de Permissões"
  default     = "AmazonS3FullAccess"
}



# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_iam_user" "example" {
  name = var.iamUserName
}

resource "aws_iam_user_login_profile" "example" {
  user                    = aws_iam_user.example.name
  password_reset_required = true
}

resource "aws_iam_user_policy_attachment" "example" {
  user       = aws_iam_user.example.name
  policy_arn = "arn:aws:iam::aws:policy/${var.policyName}"
}

# resource "aws_iam_user_policy" "example" {
#   name       = "example-user-policy"
#   user       = aws_iam_user.example.name
#   policy     = <<-EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "s3:ListAllMyBuckets",
#       "Resource": "arn:aws:s3:::*"
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_access_key" "example" {
  user = aws_iam_user.example.name
}



# Outputs
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



# Comandos à executar
# terraform output access_key_info | Out-File -FilePath "G:\Meu Drive\4_PROJ\scripts\scripts_model\terraform\.default\secrets\keyAccessTest.json" -Append
# terraform output iam_user_password | Out-File -FilePath "G:\Meu Drive\4_PROJ\scripts\scripts_model\terraform\.default\secrets\iamUserPassword.txt" -Append