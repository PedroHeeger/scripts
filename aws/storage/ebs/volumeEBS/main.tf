# Definindo Variáveis
variable "size" {
  description = "Tamanho do volume EBS em GiB"
  default     = 10
}

variable "availability_zone" {
  description = "Zona de disponibilidade para o volume EBS"
  default     = "us-east-1a"
}

variable "volume_type" {
  description = "Tipo de volume EBS"
  default     = "gp2"
}

variable "tag_name_volume" {
  description = "Nome da tag para o volume EBS"
  default     = "volumeEBSTest1"
}

variable "aws_account_id" {
  description = "ID da conta AWS"
  default     = "001727357081"
}

variable "tag_name_snapshot" {
  description = "Nome da tag para o snapshot EBS"
  default     = "snapshotEBSTest1"
}

variable "device_name" {
  description = "Nome do dispositivo para anexar o volume EBS"
  default     = "/dev/xvdf"
}

variable "tag_name_instance" {
  description = "Nome da tag para a instância EC2"
  default     = "ec2Test1"
}



# Executando o código
provider "aws" {
  region = "us-east-1"
}

# Criando o volume EBS se não existir
resource "aws_ebs_volume" "example" {
  availability_zone = var.availability_zone
  size              = var.size
  type              = var.volume_type

  tags = {
    Name = var.tag_name_volume
  }
}

# # Obtendo o ID do snapshot
# data "aws_ebs_snapshot" "example" {
#   filter {
#     name   = "tag:Name"
#     values = [var.tag_name_snapshot]
#   }
# }

# # Criando o volume EBS a partir do snapshot
# resource "aws_ebs_volume" "example" {
#   availability_zone = var.availability_zone
#   size              = var.size
#   type              = var.volume_type
#   snapshot_id       = data.aws_ebs_snapshot.example.id

#   tags = {
#     Name = var.tag_name_volume
#   }
# }

# Obtendo o ID da instância EC2
data "aws_instance" "example" {
  filter {
    name   = "tag:Name"
    values = [var.tag_name_instance]
  }
}

# Anexando o volume EBS à instância EC2
resource "aws_volume_attachment" "example" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.example.id
  instance_id = data.aws_instance.example.id
}



# Outputs
output "ebs_volume_id" {
  value       = aws_ebs_volume.example.id
}