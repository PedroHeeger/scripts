# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "keyPairName" {
  description = "Nome do par de chaves"
  default     = "keyPairTest"
}

variable "keyPairPubPath" {
  description = "Caminho para a chave pública"
  default     = "G:/Meu Drive/4_PROJ/scripts/scripts_model/terraform/.default/secrets"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = var.keyPairName
  public_key = file(var.keyPairPubPath)
}

output "private_key_pem" {
  value     = aws_key_pair.my_key_pair.key_name
  sensitive = true
}