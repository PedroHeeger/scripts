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

variable "block_public_acls" { # Impede que qualquer nova ACL pública seja aplicada a objetos no bucket. Qualquer ACL pública existente funciona.            
  description = "Configuração do bloqueio de ACLs públicas"
  type        = string
  # default     = true
  default     = false
}

variable "ignore_public_acls" { # Faz com que o bucket ignore todas as ACLs públicas existentes, independentemente de quando foram criadas. Mas permite a criação delas.
  description = "Configuração da ignorância de ACLs públicas"   
  type        = string
  # default     = true
  default     = false
}

variable "block_public_policy" { # Impede que novas políticas públicas (Bucket Policies) sejam aplicadas ao bucket. As existentes continuarão funcionando.
  description = "Configuração do bloqueio de políticas de bucket"
  type        = string
  default     = true
  # default     = false
}

variable "restrict_public_buckets" { # Restringe completamente o acesso público ao bucket, tanto por ACLs quanto por Bucket Policies, tanto novas como existentes.
  description = "Configuração da restrição de buckets públicos"
  type        = string
  # default     = true
  default     = false
}

variable "object_ownership" { # Restringe completamente o acesso público ao bucket, tanto por ACLs quanto por Bucket Policies, tanto novas como existentes.
  description = "Configuração do proprietário dos objetos no bucket"
  type        = string
  # default     = "BucketOwnerEnforced"  # O proprietário do bucket detém automaticamente a propriedade de todos os objetos, independentemente de quem os criou. Bloqueia todas as ACLs, e o bucket tem controle total sobre os objetos.
  default     = "BucketOwnerPreferred"  # O proprietário do bucket se torna automaticamente o proprietário dos objetos, a menos que o objeto tenha uma ACL específica que defina outro proprietário.
  # default     = "ObjectWriter"        # O usuário que faz o upload do objeto é o proprietário, mantendo a propriedade dos objetos que eles próprios criaram.
}

variable "canonical_user_permissions" {
  description = "Permissões para o usuário canônico"
  type        = list(string)
  # default     = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]  # Permissões totais
  default     = ["FULL_CONTROL"]                                              # Primeiro conjunto de permissões
  # default     = ["READ", "WRITE"]                                           # Segundo conjunto de permissões
  # default     = ["READ_ACP", "WRITE_ACP"]                                   # Terceiro conjunto de permissões
}

variable "authenticated_users_permissions" {
  description = "Permissões para usuários autenticados"
  type        = list(string)
  # default     = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]  # Permissões totais
  default     = []                                                            # Primeiro conjunto de permissões
  # default     = ["WRITE"]                                                   # Segundo conjunto de permissões
  # default     = ["READ_ACP", "WRITE_ACP"]                                   # Terceiro conjunto de permissões
}

variable "log_delivery_permissions" {
  description = "Permissões para entrega de logs"
  type        = list(string)
  # default     = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]  # Permissões totais
  default     = []                                                            # Primeiro conjunto de permissões
  # default     = ["WRITE"]                                                   # Segundo conjunto de permissões
  # default     = ["READ_ACP", "WRITE_ACP"]                                   # Terceiro conjunto de permissões
}

variable "all_users_permissions" {
  description = "Permissões para todos os usuários"
  type        = list(string)
  # default     = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]  # Permissões totais
  default     = ["READ"]                                                      # Primeiro conjunto de permissões
  # default     = ["FULL_CONTROL"]                                            # Segundo conjunto de permissões
  # default     = ["READ_ACP", "WRITE_ACP"]                                   # Terceiro conjunto de permissões
}



# Executando o código
provider "aws" {
  region = var.region
}

# Criando o bucket
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

# Definindo as configurações de bloqueio de acesso público
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.bucket

  block_public_acls        = var.block_public_acls
  ignore_public_acls       = var.ignore_public_acls
  block_public_policy      = var.block_public_policy
  restrict_public_buckets  = var.restrict_public_buckets
}

# Definindo o propietário do bucket
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.bucket

  rule {
    object_ownership = var.object_ownership
  }
}

# Configurando as permissões dos grupos de destinatários da ACL do bucket
data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.example.bucket
  access_control_policy {
  # Permissões para o usuário canônico
  dynamic "grant" {
    for_each = var.canonical_user_permissions
    content {
      grantee {
          id   = data.aws_canonical_user_id.current.id
          type = "CanonicalUser"
        }
        permission = grant.value
      }
  }

  # Permissões para usuários autenticados
  dynamic "grant" {
    for_each = var.authenticated_users_permissions
    content {
      grantee {
          type = "Group"
          uri  = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
        }
        permission = grant.value
      }
  }

  # Permissões para Log Delivery
  dynamic "grant" {
    for_each = var.log_delivery_permissions
    content {
      grantee {
          type = "Group"
          uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
        }
        permission = grant.value
      }
  }

  # Permissões para todos os usuários
  dynamic "grant" {
    for_each = var.all_users_permissions
    content {
      grantee {
          type = "Group"
          uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
        }
        permission = grant.value
      }
  }
      owner {
        id = data.aws_canonical_user_id.current.id
      }
  }
}



# Outputs
output "bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.example.bucket
}