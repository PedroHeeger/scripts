# Definindo Variáveis
variable "efs_token" {
  description = "Token de criação para o sistema de arquivos EFS"
  default     = "fsTokenEFSTest1"
}

variable "tag_name_fs" {
  description = "Nome da tag para o sistema de arquivos EFS"
  default     = "fsEFSTest1"
}

variable "performance_mode" {
  description = "Modo de desempenho do sistema de arquivos EFS"
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Modo de throughput do sistema de arquivos EFS"
  default     = "bursting"
}

variable "security_group_name" {
  description = "Nome do grupo de segurança"
  default     = "default"
}

variable "availability_zone" {
  description = "Zona de disponibilidade"
  default     = "us-east-1a"
}



# Executando o código
provider "aws" {
  region = "us-east-1"
}

data "aws_security_group" "example" {
  filter {
    name   = "group-name"
    values = [var.security_group_name]
  }
}

data "aws_subnet" "example" {
  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}

resource "aws_efs_file_system" "example" {
  creation_token    = var.efs_token
  performance_mode  = var.performance_mode
  throughput_mode   = var.throughput_mode

  tags = {
    Name = var.tag_name_fs
  }
}

resource "aws_efs_mount_target" "example" {
  file_system_id    = aws_efs_file_system.example.id
  subnet_id         = data.aws_subnet.example.id
  security_groups   = [data.aws_security_group.example.id]
}



# Outputs
output "efs_file_system_id" {
  value = aws_efs_file_system.example.id
}

output "mount_target_id" {
  value = aws_efs_mount_target.example.id
}