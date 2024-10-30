# Definindo Variáveis
variable "aws_account_id" {
  description = "ID da conta AWS"
  default     = "001727357081"
}

variable "tag_name_volume" {
  description = "Nome da tag para o volume EBS"
  default     = "volumeEBSTest1"
}

variable "snapshot_description" {
  description = "Descrição do snapshot"
  default     = "Snapshot Description Test 1"
}

variable "tag_name_snapshot" {
  description = "Nome da tag para o snapshot EBS"
  default     = "snapshotEBSTest1"
}



# Executando o código
provider "aws" {
  region = "us-east-1"
}

# Obtendo ID do volume EBS
data "aws_ebs_volume" "example" {
  filter {
    name   = "tag:Name"
    values = [var.tag_name_volume]
  }
}

# Obtendo o ID do volume vinculado ao snapshot baseado na tag (Caso o volume já tenha sido excluído)
# data "aws_ebs_snapshot" "example" {
#   filter {
#     name   = "tag:Name"
#     values = [var.tag_name_snapshot]
#   }
# }

# Criando o snapshot se não existir
resource "aws_ebs_snapshot" "example" {
#   volume_id         = data.aws_ebs_snapshot.example.volume_id  # Caso o volume já tenha sido excluído
  volume_id         = data.aws_ebs_volume.example.id         # Caso o volume não tenha sido excluído
  description       = var.snapshot_description

  tags = {
    Name = var.tag_name_snapshot
  }
}



# Outputs
output "ebs_snapshot_id" {
  value       = aws_ebs_snapshot.example.id
}