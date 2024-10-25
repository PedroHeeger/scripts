# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "instance_profile_name" {
  description = "Nome do perfil de instância"
  default     = "instanceProfileTest"
}

variable "iam_role_name" {
  description = "Nome da role"
  default     = "iamRoleTest"
}



# Executando o código
provider "aws" {
  region = var.region
}

# Referenciando a role existente
data "aws_iam_role" "existing" {
  name = var.iam_role_name
}

# Criando um perfil de instância
resource "aws_iam_instance_profile" "example" {
  name = var.instance_profile_name
  role = data.aws_iam_role.existing.name
}



# Saída
output "instance_profile_name" {
  value = aws_iam_instance_profile.example.name
}