# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "tagNameInstance" {
  description = "Nome da tag da instância"
  default     = "ec2Test1"
}

variable "sg_name" {
  description = "Nome do Security Group"
  default     = "default"
}

variable "aZ1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "aZ2" {
  description = "Nome da zona de disponibilidade 2"
  default     = "us-east-1b"
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

variable "deviceName" {
  description = "Nome do Dispositivo de Armazenamento"
  default     = "dev/sda1"
}

variable "volumeSize" {
  description = "Tamanho do Volume de Armazenamento"
  default     = 12
}

variable "volumeType" {
  description = "Tipo do Volume de Armazenamento"
  default     = "gp2"
}

variable "instanceProfileName" {
  description = "Nome do Perfil de Instância"
  default     = "instanceProfileTest"
}



# Executando o código
provider "aws" {
  region = var.region
}


# VPC DEFAULT
data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# VPC CREATED
# data "aws_vpcs" "existing" {
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name]
#   }
# }


# SUBNETS DEFAULT
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default.ids[0]]            # PARA VPC DEFAULT
    # values = [data.aws_vpcs.existing.ids[0]]          # PARA VPC CREATED
  }

  filter {
    name   = "availability-zone"
    values = [var.aZ1, var.aZ2]
  }
}


# SG DEFAULT
data "aws_security_group" "default" {
  name    = var.sg_name
  vpc_id = data.aws_vpcs.default.ids[0]                   # PARA VPC DEFAULT
#   vpc_id = data.aws_vpcs.existing.ids[0]                    # PARA VPC CREATED
}

# SG CREATED
# data "aws_security_group" "existing" {
#   name    = var.sg_name
#   vpc_id = data.aws_vpcs.default.ids[0]                   # PARA VPC DEFAULT
# #   vpc_id = data.aws_vpcs.existing.ids[0]                    # PARA VPC CREATED
# }


# INSTÂNCIA
# resource "aws_instance" "ec2Test" {
#   ami             = var.imageId
#   instance_type   = var.instanceType
#   key_name        = var.keyPairName
#   count           = 1
# #   security_group_ids = ["${aws_security_group.example.id}"]
# #   subnet_id       = "${aws_subnet.example.id}"

# #   user_data = file(var.userDataPath/var.userDataFile)
#   user_data = file(pathexpand("${var.userDataPath}/${var.userDataFile}"))
# #   user_data = <<-EOF
# #               #!/bin/bash
# #               echo "Hello, World!" > index.html
# #               nohup python -m SimpleHTTPServer 80 &
# #               EOF

#   tags = {
#     Name = var.tagNameInstance
#   }
# }



resource "aws_instance" "example" {
  ami             = var.imageId
  instance_type   = var.instanceType
  key_name        = var.keyPairName
  count           = 1
  vpc_security_group_ids = [data.aws_security_group.default.id]            # PARA SG DEFAULT
  # vpc_security_group_ids = [aws_security_group.existing.id]         # PARA SG CREATED
  subnet_id       = data.aws_subnets.default.ids[0]                        # PARA SUBNET DEFAULT
  # subnet_id       = data.aws_subnet.default.id                        # PARA SUBNET CREATED

  user_data = file(pathexpand("${var.userDataPath}/${var.userDataFile}"))

  tags = {
    Name = var.tagNameInstance
  }

  root_block_device {
    volume_size = var.volumeSize
    volume_type = var.volumeType
  }

  # iam_instance_profile = var.instanceProfileName
}


# Saída
output "public_ip" {
  value = aws_instance.example[0].public_ip
}