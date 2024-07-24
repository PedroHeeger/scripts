# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket S3 a ser criado"
  type        = string
  default     = "bucket-test1-ph"
}

variable "object_name" {
  description = "Nome do objeto S3 a ser criado"
  type        = string
  default     = "objTest.jpg"
}

variable "file_path" {
  description = "Caminho local do arquivo a ser enviado para o bucket S3"
  type        = string
  default     = "G:/Meu Drive/4_PROJ/scripts/scripts_model/terraform/aws/s3/object/objTest.jpg"
}

variable "storage_class" {
  description = "Classe de armazenamento do objeto S3"
  type        = string
  default     = "STANDARD"
}



# Executando o código
provider "aws" {
  region = var.region
}

# BUCKET
data "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

# OBJECT
resource "aws_s3_object" "example" {
  bucket        = data.aws_s3_bucket.example.bucket
  key           = var.object_name
  source        = var.file_path
  storage_class = var.storage_class
  acl           = "public-read"
}



# Outputs
output "object_key" {
  description = "Nome do objeto S3 criado"
  value       = aws_s3_object.example.key
}

output "object_url" {
  description = "URL do objeto S3 criado"
  value       = "https://${var.bucket_name}.s3.amazonaws.com/${var.object_name}"
}