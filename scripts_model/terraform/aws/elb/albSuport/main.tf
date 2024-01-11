# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
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
  default     = "keyPairTest"
}

variable "userDataPath" {
  description = "Caminho para o arquivo user data"
  default     = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/apache_httpd"
}

variable "userDataFile" {
  description = "Arquivo user data"
  default     = "udFile.sh"
}

variable "tgName" {
  description = "Nome do Target Group"
  default     = "tgTest1"
}

variable "lbName" {
  description = "Nome do Application Load Balancer"
  default     = "lbTest1"
}


# Executando o código
provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2Test" {
  ami             = var.imageId
  instance_type   = var.instanceType
  key_name        = var.keyPairName
  count           = 2
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
    Name = "${var.tagNameInstance}${count.index + 1}"
  }
}

data "aws_lb_target_group" "tgTest1" {
  name = var.tgName
}

resource "aws_lb_target_group_attachment" "instance_attachment_1" {
  target_group_arn = data.aws_lb_target_group.tgTest1.arn
  target_id        = aws_instance.ec2Test[0].id
}

resource "aws_lb_target_group_attachment" "instance_attachment_2" {
  target_group_arn = data.aws_lb_target_group.tgTest1.arn
  target_id        = aws_instance.ec2Test[1].id
}

data "aws_lb" "lbTest1" {
  name = var.lbName
}


# Saída
output "public_ip_instance_1" {
  value = aws_instance.ec2Test[0].public_ip
}

output "public_ip_instance_2" {
  value = aws_instance.ec2Test[1].public_ip
}

output "load_balancer_dns" {
  value = data.aws_lb.lbTest1.dns_name
}