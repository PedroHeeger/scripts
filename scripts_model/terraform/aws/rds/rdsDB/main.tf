# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "db_instance_name" {
  description = "Nome da instância de banco de dados"
  default     = "db-instance-test1"
}

variable "db_instance_class" {
  description = "Classe da instância de banco de dados"
  default     = "db.t3.micro"
}

variable "engine" {
  description = "Tipo de banco de dados"
  default     = "postgres"
}

variable "engine_version" {
  description = "Versão do banco de dados"
  default     = "16.1"
}

variable "master_username" {
  description = "Nome de usuário do mestre"
  default     = "masterUsernameTest1"
}

variable "master_password" {
  description = "Senha do mestre"
  default     = "masterPasswordTest1"
}

variable "allocated_storage" {
  description = "Armazenamento alocado em GB"
  default     = 20
}

variable "storage_type" {
  description = "Tipo de armazenamento"
  default     = "gp2"
}

variable "db_name" {
  description = "Nome do banco de dados"
  default     = "dbTest1"
}

variable "period_backup" {
  description = "Período de retenção de backup em dias"
  default     = 7
}

variable "sg_name" {
  description = "Nome do grupo de segurança"
  default     = "default"
}

variable "az" {
  description = "Zona de disponibilidade"
  default     = "us-east-1a"
}


# Executando o código
provider "aws" {
  region = var.region
}


data "aws_security_group" "sg" {
  name = var.sg_name
}

data "aws_subnet" "subnet" {
  availability_zone = var.az
}

resource "aws_db_instance" "example" {
  identifier              = var.db_instance_name
  instance_class          = var.db_instance_class
  engine                  = var.engine
  engine_version          = var.engine_version
  db_name                 = var.db_name
  username                = var.master_username
  password                = var.master_password
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  vpc_security_group_ids = [data.aws_security_group.sg.id]
  availability_zone       = var.az
  backup_retention_period = var.period_backup
  skip_final_snapshot     = true
}


# Saída
output "db_instance_identifier" {
  value = aws_db_instance.example.identifier
}