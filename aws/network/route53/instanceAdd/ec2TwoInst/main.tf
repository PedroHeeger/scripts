# Definindo Variáveis
variable "region1" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "region2" {
  description = "Região da AWS"
  type        = string
  default     = "sa-east-1"
}

variable "tag_name_instanceA" {
  description = "Nome da tag da instância"
  type        = string
  default     = "ec2R53Test1"
}

variable "tag_name_instanceB" {
  description = "Nome da tag da instância"
  type        = string
  default     = "ec2R53Test2"
}

variable "az" {
  description = "Nome da zona de disponibilidade 1"
  type        = string
  default     = "us-east-1a"
}

variable "other_az" {
  description = "Nome da zona de disponibilidade 2"
  type        = string
  default     = "sa-east-1a"
}

variable "sg_name" {
  description = "Nome do Security Group"
  type        = string
  default     = "default"
}

variable "image_idA" {
  description = "Imagem Id da instância 1"
  type        = string
  default     = "ami-0c7217cdde317cfec"       # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
}

variable "image_idB" {
  description = "Imagem Id da instância 2"
  type        = string
  default     = "ami-0f16d0d3ac759edfa"      # Canonical, Ubuntu, 24.04, amd64 noble image
}

variable "instance_type" {
  description = "Tipo da instância"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_nameA" {
  description = "Nome do par de chaves 1"
  type        = string
  default     = "keyPairUniversal"
}

variable "key_pair_nameB" {
  description = "Nome do par de chaves 2"
  type        = string
  default     = "keyPairTest"
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




# Executando o código
# INSTÂNCIA NA REGIÃO PADRÃO
provider "aws" {
  alias  = "primary"
  region = var.region1
}

# VPC DEFAULT
data "aws_vpcs" "default" {
  provider = aws.primary
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# VPC CREATED
# data "aws_vpcs" "existing" {
#   provider = aws.primary
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name]
#   }
# }


# SUBNETS DEFAULT
data "aws_subnets" "default" {
  provider = aws.primary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default.ids[0]]            # PARA VPC DEFAULT
    # values = [data.aws_vpcs.existing.ids[0]]          # PARA VPC CREATED
  }

  filter {
    name   = "availability-zone"
    values = [var.az]
  }
}


# SG DEFAULT
data "aws_security_group" "default" {
  provider = aws.primary
  name    = var.sg_name
  vpc_id = data.aws_vpcs.default.ids[0]                   # PARA VPC DEFAULT
#   vpc_id = data.aws_vpcs.existing.ids[0]                    # PARA VPC CREATED
}

# SG CREATED
# data "aws_security_group" "existing" {
#   provider = aws.primary
#   name    = var.sg_name
#   vpc_id = data.aws_vpcs.default.ids[0]                   # PARA VPC DEFAULT
# #   vpc_id = data.aws_vpcs.existing.ids[0]                    # PARA VPC CREATED
# }


# Criando a instância EC2 na região padrão
resource "aws_instance" "example" {
  provider        = aws.primary
  ami             = var.image_idA
  instance_type   = var.instance_type
  key_name        = var.key_pair_nameA
  count           = 1
  vpc_security_group_ids = [data.aws_security_group.default.id]            # PARA SG DEFAULT
  # vpc_security_group_ids = [aws_security_group.existing.id]         # PARA SG CREATED
  subnet_id       = data.aws_subnets.default.ids[0]                        # PARA SUBNET DEFAULT
  # subnet_id       = data.aws_subnet.default.id                        # PARA SUBNET CREATED

  user_data = file(pathexpand("${var.user_data_path}/${var.user_data_file}"))

  tags = {
    Name = "${var.tag_name_instanceA}"
  }
  
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  # iam_instance_profile = var.instance_profile_name
}




# INSTÂNCIA NA OUTRA REGIÃO
provider "aws" {
  alias  = "secondary"
  region = var.region2
}


# VPC DEFAULT
data "aws_vpcs" "default_other_region" {
  provider = aws.secondary
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# VPC CREATED
# data "aws_vpcs" "existing_other_region" {
#   provider = aws.secondary
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name]
#   }
# }


# SUBNETS DEFAULT
data "aws_subnets" "default_other_region" {
  provider = aws.secondary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default_other_region.ids[0]]            # PARA VPC DEFAULT
    # values = [data.aws_vpcs.existing_other_region.ids[0]]          # PARA VPC CREATED
  }

  filter {
    name   = "availability-zone"
    values = [var.other_az]
  }
}


# SG DEFAULT
data "aws_security_group" "default_other_region" {
  provider = aws.secondary
  name    = var.sg_name
  vpc_id = data.aws_vpcs.default_other_region.ids[0]                   # PARA VPC DEFAULT
#   vpc_id = data.aws_vpcs.existing_other_region.ids[0]                    # PARA VPC CREATED
}

# SG CREATED
# data "aws_security_group" "existing_other_region" {
#   provider = aws.secondary
#   name    = var.sg_name
#   vpc_id = data.aws_vpcs.default_other_region.ids[0]                   # PARA VPC DEFAULT
# #   vpc_id = data.aws_vpcs.existing_other_region.ids[0]                    # PARA VPC CREATED
# }


# Criando a instância EC2 da outra região
resource "aws_instance" "example_other_region" {
  provider        = aws.secondary
  ami             = var.image_idB
  instance_type   = var.instance_type
  key_name        = var.key_pair_nameB
  count           = 1
  vpc_security_group_ids = [data.aws_security_group.default_other_region.id]            # PARA SG DEFAULT
  # vpc_security_group_ids = [aws_security_group.existing_other_region.id]         # PARA SG CREATED
  subnet_id       = data.aws_subnets.default_other_region.ids[0]                        # PARA SUBNET DEFAULT
  # subnet_id       = data.aws_subnet.default_other_region.id                        # PARA SUBNET CREATED

  user_data = file(pathexpand("${var.user_data_path}/${var.user_data_file}"))

  tags = {
    Name = "${var.tag_name_instanceB}"
  }
  
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  # iam_instance_profile = var.instance_profile_name
}




# Saída
output "public_ip_instance_1" {
  value = aws_instance.example[0].public_ip
}

output "public_ip_instance_2" {
  value = aws_instance.example_other_region[0].public_ip
}