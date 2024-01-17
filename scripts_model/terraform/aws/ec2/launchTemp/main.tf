# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "launchTempName" {
  description = "Nome do Launch Template"
  default     = "launchTempTest1"
}

variable "versionDescription" {
  description = "Descrição da versão do Launch Template"
  default     = "My version 1"
}

variable "aZ1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "tagNameInstance" {
  description = "Nome da tag da instância"
  default     = "ec2Test"
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
  default     = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/httpd_stress"
}

variable "userDataFile" {
  description = "Arquivo user data"
  default     = "udFileBase64.txt"
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_vpcs" "default_vpc" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_security_group" "default" {
  name        = "default"
  vpc_id      = data.aws_vpcs.default_vpc.ids[0]
}


# LAUNCH TEMPLATE 1
# resource "aws_launch_template" "example" {
#   name = var.launchTempName
#   description = var.versionDescription

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       volume_size = 8
#       volume_type = "gp2"
#     }
#   }

#   image_id        = var.imageId
#   instance_type   = var.instanceType
#   key_name        = var.keyPairName
#   user_data = file(pathexpand("${var.userDataPath}/${var.userDataFile}"))
#   vpc_security_group_ids = [data.aws_security_group.default.id]
# }


# LAUNCH TEMPLATE 2
data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default_vpc.ids[0]]
  }

  filter {
    name   = "availability-zone"
    values = [var.aZ1]
  }
}

data "aws_subnet" "selected_default_subnet" {
  for_each = toset(data.aws_subnets.default_subnet.ids)
  id       = each.value
}

resource "aws_launch_template" "example" {
  name = var.launchTempName
  description = var.versionDescription

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  dynamic network_interfaces {
    for_each = data.aws_subnet.selected_default_subnet

    content {
      associate_public_ip_address = true
      subnet_id                  = network_interfaces.value.id
      security_groups            = [data.aws_security_group.default.id]
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.tagNameInstance
    }
  }

  image_id        = var.imageId
  instance_type   = var.instanceType
  key_name        = var.keyPairName
  user_data = file(pathexpand("${var.userDataPath}/${var.userDataFile}"))
}