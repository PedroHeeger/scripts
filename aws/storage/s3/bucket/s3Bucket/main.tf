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



# Executando o código
provider "aws" {
  region = var.region
}

# BUCKET
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

# BUCKET PUBLIC ACCESS
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.bucket

  block_public_acls       = false
  ignore_public_acls       = false
  block_public_policy      = true
  restrict_public_buckets  = false
}

# CONTROL OBJECT OWNERSHIP
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# BUCKET ACL
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.bucket
  acl    = "public-read"

  depends_on = [aws_s3_bucket_ownership_controls.example]
}



# Outputs
output "bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.example.bucket
}