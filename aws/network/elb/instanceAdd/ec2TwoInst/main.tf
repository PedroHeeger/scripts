# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "tag_name_instance" {
  description = "Nome da tag da instância"
  type        = string
  default     = "ec2ELBTest"
}

variable "sg_name" {
  description = "Nome do Security Group"
  type        = string
  default     = "default"
}

variable "az1" {
  description = "Nome da zona de disponibilidade 1"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Nome da zona de disponibilidade 2"
  type        = string
  default     = "us-east-1b"
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
  default     = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd"
}

variable "user_data_file" {
  description = "Arquivo user data"
  type        = string
  default     = "udFileDeb.sh"
}

variable "device_name" {
  description = "Nome do Dispositivo de Armazenamento"
  type        = string
  default     = "dev/sda1"
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
  default     = "instanceProfileTest"
}

variable "tg_name" {
  description = "Nome do Target Group"
  type        = string
  default     = "tgTest1"
}

variable "elb_name" {
  description = "Nome do Application Load Balancer"
  type        = string
  default     = "albTest1"
  # default     = "clbTest1"
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
    values = [var.az1, var.az2]
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


# Criando duas instâncias EC2
resource "aws_instance" "example" {
  ami             = var.image_id
  instance_type   = var.instance_type
  key_name        = var.key_pair_name
  count           = 2
  vpc_security_group_ids = [data.aws_security_group.default.id]            # PARA SG DEFAULT
  # vpc_security_group_ids = [aws_security_group.existing.id]         # PARA SG CREATED
  subnet_id       = data.aws_subnets.default.ids[0]                        # PARA SUBNET DEFAULT
  # subnet_id       = data.aws_subnet.default.id                        # PARA SUBNET CREATED

#   user_data = file(var.user_data_path/var.user_data_file)
  user_data = file(pathexpand("${var.user_data_path}/${var.user_data_file}"))
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World!" > index.html
#               nohup python -m SimpleHTTPServer 80 &
#               EOF

  tags = {
    Name = "${var.tag_name_instance}${count.index + 1}"
  }
  
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  # iam_instance_profile = var.instance_profile_name
}


# Extraindo o Target Group
data "aws_lb_target_group" "existing" {
  name = var.tg_name
}

# Vinculando a instância 1 ao Target Group
resource "aws_lb_target_group_attachment" "example_1" {
  target_group_arn = data.aws_lb_target_group.existing.arn
  target_id        = aws_instance.example[0].id
}

# Vinculando a instância 1 ao Target Group
resource "aws_lb_target_group_attachment" "example_2" {
  target_group_arn = data.aws_lb_target_group.existing.arn
  target_id        = aws_instance.example[1].id
}

# Extraindo o Load Balancer
data "aws_lb" "existing" {
  name = var.elb_name
}


# # Extraindo o Classic Load Balancer existente
# data "aws_elb" "existing" {
#   name = var.elb_name
# }

# # Associando as instâncias ao Classic Load Balancer existente
# resource "aws_elb_attachment" "example" {
#   count         = 2
#   elb           = data.aws_elb.existing.name
#   instance      = aws_instance.example[count.index].id
# }




# Saída
output "public_ip_instance_1" {
  value = aws_instance.example[0].public_ip
}

output "public_ip_instance_2" {
  value = aws_instance.example[1].public_ip
}

output "load_balancer_dns" {
  value = data.aws_lb.existing.dns_name
  # value = data.aws_elb.existing.dns_name
}