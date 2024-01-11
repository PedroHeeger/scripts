# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "tagNameInstance" {
  description = "Nome da tag da instância"
  default     = "ec2Test1"
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
  default     = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/basic/"
}

variable "userDataFile" {
  description = "Arquivo user data"
  default     = "udFile.sh"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2Test" {
  ami             = var.imageId
  instance_type   = var.instanceType
  key_name        = var.keyPairName
  count           = 1
#   security_group_ids = ["${aws_security_group.example.id}"]
#   subnet_id       = "${aws_subnet.example.id}"

#   user_data = file(var.userDataPath/var.userDataFile)
  user_data = file(pathexpand("${var.userDataPath}/${var.userDataFile}"))
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World!" > index.html
#               nohup python -m SimpleHTTPServer 80 &
#               EOF

  tags = {
    Name = var.tagNameInstance
  }
}

# resource "aws_security_group" "example" {
#   # Defina suas configurações de grupo de segurança aqui
# }

# resource "aws_subnet" "example" {
#   # Defina suas configurações de sub-rede aqui
# }


# Saída
output "public_ip" {
  value = aws_instance.ec2Test[0].public_ip
}