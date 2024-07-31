# Definindo Variáveis
variable "region1" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "region2" {
  description = "Região da AWS"
  default     = "eu-west-3"
}

variable "hosted_zone_name" {
  description = "Nome da hosted zone no Route 53"
  default     = "pedroheeger.dev.br."
}

variable "domain_name" {
  description = "Nome de domínio associado à zona hospedada"
  default     = "pedroheeger.dev.br"
}

variable "resource_record_name" {
  description = "Nome do registro de recurso a ser criado"
  default     = "www.pedroheeger.dev.br"
}

variable "resource_record_type" {
  description = "Tipo do registro de recurso a ser criado"
  default     = "A"
}

variable "ttl" {
  description = "Tempo em segundos que um registro DNS deve ser armazenado em cache por outros sistemas"
  default     = 300
}

variable "tag_name_instance1" {
  description = "Nome da tag da instância primária do EC2"
  default     = "ec2Test1"
}

variable "tag_name_instance2" {
  description = "Nome da tag da instância secundária do EC2"
  default     = "ec2Test2"
}

variable "failover_record_type1" {
  description = "Tipo de failover do registro primário"
  default     = "PRIMARY"
}

variable "failover_record_type2" {
  description = "Tipo de failover do registro secundário"
  default     = "SECONDARY"
}

variable "record_id1" {
  description = "Identificador do registro primário."
  type        = string
  # default     = "Primary"
  default     = "US-NorthVirginia"
}

variable "record_id2" {
  description = "Identificador do registro secundário."
  type        = string
  # default     = "Secondary"
  default     = "Europe-Paris"
}


variable "health_check_name" {
  description = "Nome da verificação de integridade"
  default     = "healthCheckTest4"
}

variable "ip_address" {
  description = "Endereço de IP verificado"
  default     = "175.184.182.193"
}

variable "port_number" {
  description = "Número da porta que a verificação de integridade será executada"
  default     = 80
}

variable "type_protocol" {
  description = "Tipo de protocolo para verificação de integridade"
  default     = "HTTP"
}

variable "resource_path" {
  description = "Caminho (path) para verificação de integridade"
  default     = "/"
}

variable "request_interval" {
  description = "Intervalo entre as verificações"
  default     = 30
}

variable "failure_threshold" {
  description = "Número de verificações de integridade consecutivas que pode falhar (Limite de falhas)"
  default     = 3
}


variable "country_code1" {
  description = "Código do país para a primeira geolocalização."
  type        = string
  default     = "US"
}

variable "country_code2" {
  description = "Código do país para a segunda geolocalização."
  type        = string
  default     = "FR"
}

variable "subdivision_code1" {
  description = "Código da subdivisão para a primeira geolocalização."
  type        = string
  default     = "VA"
}



# Executando o código
provider "aws" {
  region = var.region1
}

data "aws_route53_zone" "example" {
  name = var.hosted_zone_name
}

data "aws_instance" "example_primary" {
  filter {
    name   = "tag:Name"
    values = [var.tag_name_instance1]
  }
}

data "aws_instance" "example_secondary" {
  filter {
    name   = "tag:Name"
    values = [var.tag_name_instance2]
  }
}


# # SIMPLE ROUTING POLICY
# resource "aws_route53_record" "example" {
#   zone_id = data.aws_route53_zone.example.zone_id
#   name    = var.resource_record_name
#   type    = var.resource_record_type
#   ttl     = var.ttl
#   records = [data.aws_instance.example_primary.public_ip]
# }


# FAILOVER POLICY
resource "aws_route53_health_check" "example" {
  ip_address        = data.aws_instance.example_primary.public_ip
  # ip_address        = var.ip_address
  port              = var.port_number
  type              = var.type_protocol
  resource_path     = var.resource_path
  request_interval  = var.request_interval
  failure_threshold = var.failure_threshold

  tags = {
    Name = var.health_check_name
  }
}

resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = var.resource_record_name
  type    = var.resource_record_type
  ttl     = var.ttl

  records = [data.aws_instance.example_primary.public_ip]

  set_identifier = var.record_id1
  failover_routing_policy {
    type = var.failover_record_type1
  }
  health_check_id = aws_route53_health_check.example.id
}

resource "aws_route53_record" "secondary" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = var.resource_record_name
  type    = var.resource_record_type
  ttl     = var.ttl

  records = [data.aws_instance.example_secondary.public_ip]

  set_identifier = var.record_id2
  failover_routing_policy {
    type = var.failover_record_type2
  }
#   health_check_id = data.aws_route53_health_check.example[var.health_check_name].id
}


# GEOLOCATION POLICY
# provider "aws" {
#   alias  = "primary"
#   region = var.region1
# }

# provider "aws" {
#   alias  = "secondary"
#   region = var.region2
# }

# data "aws_route53_zone" "example" {
#   name = var.hosted_zone_name
# }

# data "aws_instance" "example_primary" {
#   provider = aws.primary
#   filter {
#     name   = "tag:Name"
#     values = [var.tag_name_instance1]
#   }
# }

# data "aws_instance" "example_secondary" {
#   provider = aws.secondary
#   filter {
#     name   = "tag:Name"
#     values = [var.tag_name_instance2]
#   }
# }

# resource "aws_route53_record" "primary" {
#   zone_id = data.aws_route53_zone.example.zone_id
#   name    = var.resource_record_name
#   type    = var.resource_record_type
#   ttl     = var.ttl

#   records = [
#     data.aws_instance.example_primary.public_ip
#   ]

#   set_identifier = var.record_id1
#   geolocation_routing_policy {
#     country = var.country_code1
#     subdivision = var.subdivision_code1
#   }
# }

# resource "aws_route53_record" "secondary" {
#   zone_id = data.aws_route53_zone.example.zone_id
#   name    = var.resource_record_name
#   type    = var.resource_record_type
#   ttl     = var.ttl

#   records = [
#     data.aws_instance.example_secondary.public_ip
#   ]

#   set_identifier = var.record_id2
#   geolocation_routing_policy {
#     country = var.country_code2
#   }
# }