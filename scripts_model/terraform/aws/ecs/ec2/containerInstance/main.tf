# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "tagNameInstance" {
  description = "Nome da tag da instância"
  default     = "containerInstance"
}

variable "sgName" {
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
  default     = "ami-079db87dc4c10ac91"    # Amazon Linux 2023 AMI 2023.3.20231218.0 x86_64 HVM kernel-6.1
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
  default     = 8
}

variable "volumeType" {
  description = "Tipo do Volume de Armazenamento"
  default     = "gp2"
}

variable "instanceProfileName" {
  description = "Nome do perfil de instância"
  default     = "instanceProfileTest"
}

variable "clusterName" {
  description = "Nome do cluster ECS"
  default     = "clusterEC2Test1"
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
  name    = var.sgName
  vpc_id = data.aws_vpcs.default.ids[0]                   # PARA VPC DEFAULT
#   vpc_id = data.aws_vpcs.existing.ids[0]                    # PARA VPC CREATED
}


# CONTAINER INSTANCE
resource "aws_instance" "example" {
  ami             = var.imageId
  instance_type   = var.instanceType
  key_name        = var.keyPairName
  count           = 2
  vpc_security_group_ids = [data.aws_security_group.default.id]            # PARA SG DEFAULT
  subnet_id       = data.aws_subnets.default.ids[0]                        # PARA SUBNET DEFAULT

  tags = {
    Name = "${var.tagNameInstance}${count.index + 1}"
  }

  root_block_device {
    volume_size = var.volumeSize
    volume_type = var.volumeType
  }

  iam_instance_profile = var.instanceProfileName

  user_data = <<-EOF
    #!/bin/bash
    echo 'EXECUTANDO O SCRIPT BASH'
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Atualizando os pacotes'
    sudo yum update -y
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Atualizando o sistema'
    sudo yum upgrade -y
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Criando o diretório do ECS'        
    sudo mkdir -p /etc/ecs
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Criando o diretório do ECS'  
    echo "ECS_CLUSTER=${var.clusterName}" | sudo tee -a /etc/ecs/ecs.config
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Aguardando alguns segundos (TEMPO 1)'  
    sleep 20
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Instalando o agente do ECS'  
    sudo yum install -y ecs-init
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Aguardando alguns segundos (TEMPO 2)'
    sleep 60
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Habilitando o ECS'  
    sudo systemctl enable ecs
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Aguardando alguns segundos (TEMPO 3)'  
    sleep 60
    echo '-----//-----//-----//-----//-----//-----//-----'
    echo 'Reiniciando o sistema'  
    sudo reboot
  EOF
}