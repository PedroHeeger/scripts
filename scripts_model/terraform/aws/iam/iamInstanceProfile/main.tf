# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "instanceProfileName" {
  description = "Nome do perfil de instância"
  default     = "instanceProfileTest"
}

variable "roleName" {
  description = "Nome da role"
  default     = "roleServiceTest"
}



# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_iam_instance_profile" "example" {
  name = var.instanceProfileName
}

resource "aws_iam_instance_profile_role_attachment" "example" {
  instance_profile = aws_iam_instance_profile.example.name
  role             = var.roleName
}