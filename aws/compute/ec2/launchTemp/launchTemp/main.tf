# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "launch_temp_name" {
  description = "Nome do Launch Template"
  type        = string
  default     = "launchTempTest1"
}

variable "version_description" {
  description = "Descrição da versão do Launch Template"
  type        = string
  default     = "My version "
}

variable "image_id" {
  description = "Imagem Id da instância"
  type        = string
  default     = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_type" {
  description = "Tipo da instância"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Nome do par de chaves"
  type        = string
  default     = "keyPairUniversal"
}

variable "user_data_path" {
  description = "Caminho para o arquivo user data"
  type        = string
  default     = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd_stress"
}

variable "user_data_file" {
  description = "Arquivo user data"
  type        = string
  default     = "udFileDebBase64.txt"
}

variable "device_name" {
  description = "Nome do Dispositivo de Armazenamento"
  type        = string
  default     = "dev/xvda"
}

variable "volume_size" {
  description = "Tamanho do Volume de Armazenamento"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "Tipo do Volume de Armazenamento"
  type        = string
  default     = "gp2"
}

variable "instance_profile_name" {
  description = "Nome do Perfil de Instância"
  type        = string
  # default     = "instanceProfileTest"
  default     = "ecsInstanceRole"
}

variable "vpc_name" {
  description = "Nome da VPC"
  type        = string
  default     = "default"
  # default     = "vpcTest1"
}

variable "az1" {
  description = "Nome da zona de disponibilidade 1"
  type        = string
  default     = "us-east-1a"
}

variable "sg_name" {
  description = "Nome do Security Group"
  type        = string
  default     = "default"
  # default     = "sgTest1"
}

variable "tag_name_instance" {
  description = "Nome da tag da instância"
  type        = string
  default     = "ec2Test"
}




# Executando o código
provider "aws" {
  region = var.region
}

# Verificando se existe um launch template com mesmo nome
data "aws_launch_template" "existing" {
  # count = length(try([for launch_template in data.aws_launch_template.existing : launch_template], [])) > 0 ? 1 : 0
  # count = length(try(data.aws_launch_template.existing, [])) > 0 ? 1 : 0
  # count = length(try(var.launch_temp_name, "")) > 0 || length(try([for lt in data.aws_launch_template.existing : lt], [])) > 0 ? 1 : 0
  # count = try(length(var.launch_temp_name), 0) > 0 ? 1 : 0
  count = length(try(var.launch_temp_name, "")) > 0 ? 1 : 0
  # name = var.launch_temp_name
}

# Verificando se a versão do launch template. Caso ele não exista, indicando como versão 0.
locals {
  existing_version = length(data.aws_launch_template.existing) > 0 ? tonumber(data.aws_launch_template.existing[0].latest_version) : 0
  next_version     = local.existing_version + 1
}

# # Output para mostrar a variável local.next_version
output "next_version" {
  value = local.next_version
}

# Output para mostrar a variável local.next_version
# output "test" {
#   value = data.aws_launch_template.existing
# }


# VPC DEFAULT
data "aws_vpcs" "example" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# # VPC CREATED
# data "aws_vpcs" "example" {
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name]
#   }
# }


# Extraindo o grupo de segurança padrão
data "aws_security_group" "example" {
  name        = var.sg_name
  vpc_id      = data.aws_vpcs.example.ids[0]
}


# # LAUNCH TEMPLATE 1
# # Criando o Launch Template do tipo 1
resource "aws_launch_template" "example" {
  name                   = var.launch_temp_name
  description            = "${var.version_description} - v${local.next_version}"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  user_data              = file(pathexpand("${var.user_data_path}/${var.user_data_file}"))
  vpc_security_group_ids = [data.aws_security_group.example.id]
  default_version        = local.next_version

  block_device_mappings {
    device_name = var.device_name

    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }
}



# # LAUNCH TEMPLATE 2
# # Extraindo as sub-redes padrões
# data "aws_subnets" "example" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpcs.example.ids[0]]
#   }

#   filter {
#     name   = "availability-zone"
#     values = [var.az1]
#   }
# }

# data "aws_subnet" "example" {
#   for_each = toset(data.aws_subnets.example.ids)
#   id       = each.value
# }

# # Criando o Launch Template do tipo 2
# resource "aws_launch_template" "example" {
#   name            = var.launch_temp_name
#   description     = "${var.version_description} - v${local.next_version}"
#   image_id        = var.image_id
#   instance_type   = var.instance_type
#   key_name        = var.key_pair_name
#   user_data       = file(pathexpand("${var.user_data_path}/${var.user_data_file}"))
#   default_version = local.next_version

#   block_device_mappings {
#     device_name = var.device_name

#     ebs {
#       volume_size = var.volume_size
#       volume_type = var.volume_type
#     }
#   }

#   dynamic network_interfaces {
#     for_each = data.aws_subnet.example

#     content {
#       associate_public_ip_address = true
#       subnet_id                   = network_interfaces.value.id
#       security_groups             = [data.aws_security_group.example.id]
#     }
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = var.tag_name_instance
#     }
#   }
# }