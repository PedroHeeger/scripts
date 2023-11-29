# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "iamUserName" {
  description = "Nome do usuário do IAM"
  default     = "iamUserTest"
}

variable "userPassword" {
  description = "Senha do usuário do IAM"
  default     = "Senha123!"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_iam_user" "example_user" {
  name = var.iamUserName
}

# resource "aws_iam_user_login_profile" "example_user_login_profile" {
#   user                    = aws_iam_user.example_user.name
#   password_reset_required = false
#   password                = var.userPassword
# }

# resource "aws_iam_user_policy_attachment" "example_user_policy_attachment" {
#   user       = aws_iam_user.example_user.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

# resource "aws_iam_user_policy" "example_user_policy" {
#   name       = "example-user-policy"
#   user       = aws_iam_user.example_user.name
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

resource "aws_iam_access_key" "example_user_access_key" {
  user = aws_iam_user.example_user.name
}


# Saída
output "access_key_info" {
  value = {
    access_key_id     = aws_iam_access_key.example_user_access_key.id,
    secret_access_key = aws_iam_access_key.example_user_access_key.secret
  }
  sensitive = true
}