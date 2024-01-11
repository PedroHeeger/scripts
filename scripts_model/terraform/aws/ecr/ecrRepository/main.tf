# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "repositoryName" {
  description = "Nome do repositório do Amazon ECR"
  default     = "repository_test1"
}

variable "tagNameInstance" {
  description = "Nome da tag da instância"
  default     = "ec2Test2"
}

variable "imageId" {
  description = "Imagem Id da instância"
  default     = "ami-0fc5d935ebf8bc3bc"
}

variable "instanceType" {
  description = "Tipo da instância"
  default     = "t2.micro"
}

variable "keyPairName" {
  description = "Nome do par de chaves"
  default     = "keyPairUniversal"
}

variable "userDataPath" {
  description = "Caminho para o arquivo user data"
  default     = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/aws_dock"
}

variable "userDataFile" {
  description = "Arquivo user data"
  default     = "udFile.sh"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "meu_repositorio_ecr" {
  name = var.repositoryName
  image_tag_mutability = "MUTABLE"  # As tags podem ser sobrescritas ou "IMMUTABLE" para que não sejam
}

resource "aws_instance" "ec2Test" {
  ami             = var.imageId
  instance_type   = var.instanceType
  key_name        = var.keyPairName
  count           = 1

  user_data = file(pathexpand("${var.userDataPath}/${var.userDataFile}"))

  tags = {
    Name = var.tagNameInstance
  }
}


# Saída
output "public_ip" {
  value = aws_instance.ec2Test[0].public_ip
}