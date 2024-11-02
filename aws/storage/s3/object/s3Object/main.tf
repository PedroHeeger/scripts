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
  default     = "G:/Meu Drive/4_PROJ/scripts/aws/storage/s3/object/objTest.jpg"
}

variable "storage_class" {
  description = "Classe de armazenamento do objeto S3"
  type        = string
  default     = "STANDARD"
}

variable "acl" {
  description = "Permissões gerais para todos os grupos de destinatários da ACL"
  type        = string
  default     = "private"
  # default     = "public-read"
  # default     = "public-read-write"
  # default     = "aws-exec-read"
  # default     = "authenticated-read"
  # default     = "bucket-owner-read"
  # default     = "bucket-owner-full-control"

}

variable "canonical_user_permissions" {
  description = "Permissões para o usuário canônico"
  type        = list(string)
  # default     = ["READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]    # Permissões totais
  default     = ["FULL_CONTROL"]                                       # Primeiro conjunto de permissões
  # default     = ["READ", ]                                           # Segundo conjunto de permissões
  # default     = ["READ_ACP", "WRITE_ACP"]                            # Terceiro conjunto de permissões
}

variable "authenticated_users_permissions" {
  description = "Permissões para usuários autenticados"
  type        = list(string)
  # default     = ["READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]    # Permissões totais
  default     = []                                                     # Primeiro conjunto de permissões
  # default     = []                                                   # Segundo conjunto de permissões
  # default     = ["READ_ACP", "WRITE_ACP"]                            # Terceiro conjunto de permissões
}

variable "all_users_permissions" {
  description = "Permissões para todos os usuários"
  type        = list(string)
  # default     = ["READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]    # Permissões totais
  default     = ["READ"]                                               # Primeiro conjunto de permissões
  # default     = ["FULL_CONTROL"]                                     # Segundo conjunto de permissões
  # default     = ["READ_ACP", "WRITE_ACP"]                            # Terceiro conjunto de permissões
}



# Executando o código
provider "aws" {
  region = var.region
}

# Extraindo o bucket existente
data "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

# Criando o objeto a partir do arquivo local
resource "aws_s3_object" "example" {
  bucket        = data.aws_s3_bucket.example.bucket
  key           = var.object_name
  source        = var.file_path
  storage_class = var.storage_class
  acl           = var.acl
  content_type  = "image/jpg"  
}

# # Configuração da ACL detalhada para o objeto (Infelizmente esse recurso não existe no Terraform. Dessa forma, não tem como estabelecer as permissões para os grupos de destinatários da ACL do objeto com granularidade. As permissões são estabelecidas iguais para todos os grantees, ou executar o código com a CLI ou SDK)
# resource "aws_s3_object_acl" "example" {
#   bucket = data.aws_s3_bucket.example.bucket
#   key    = var.object_name

#   # Permissões para o usuário canônico
#   dynamic "grant" {
#     for_each = var.canonical_user_permissions
#     content {
#       grantee {
#         type = "CanonicalUser"
#         id   = var.id_canonical_user
#       }
#       permission = grant.value
#     }
#   }

#   # Permissões para usuários autenticados
#   dynamic "grant" {
#     for_each = var.authenticated_users_permissions
#     content {
#       grantee {
#         type = "Group"
#         uri  = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
#       }
#       permission = grant.value
#     }
#   }

#   # Permissões para todos os usuários
#   dynamic "grant" {
#     for_each = var.all_users_permissions
#     content {
#       grantee {
#         type = "Group"
#         uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
#       }
#       permission = grant.value
#     }
#   }
# }



# Outputs
output "object_key" {
  description = "Nome do objeto S3 criado"
  value       = aws_s3_object.example.key
}

output "object_url" {
  description = "URL do objeto S3 criado"
  value       = "https://${var.bucket_name}.s3.amazonaws.com/${var.object_name}"
}