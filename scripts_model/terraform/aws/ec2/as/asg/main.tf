# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "asgName" {
  description = "Nome do Auto Scaling Group"
  default     = "asgTest1"
}

variable "launchTempName" {
  description = "Nome do Launch Template"
  default     = "launchTempTest1"
}

variable "launchTempVersion" {
  description = "Versão do Launch Template"
  default     = 1
}

variable "tgName" {
  description = "Nome do Target Group"
  default     = "tgTest1"
}

variable "aZ1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "aZ2" {
  description = "Nome da zona de disponibilidade 2"
  default     = "us-east-1b"
}

variable "tagNameInstance" {
  description = "Nome da tag da instância"
  default     = "ec2Test"
}

variable "clbName" {
  description = "Nome do Classic Load Balancer (CLB)"
  default     = "clbTest1"
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_launch_template" "example" {
  name = var.launchTempName
}


# AUTO SCALING GROUP 1
# data "aws_vpcs" "default_vpc" {
#   filter {
#     name   = "isDefault"
#     values = ["true"]
#   }
# }

# data "aws_subnets" "default_subnet" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpcs.default_vpc.ids[0]]
#   }

#   filter {
#     name   = "availability-zone"
#     values = [var.aZ1, var.aZ2]
#   }
# }

# data "aws_subnet" "selected_default_subnet" {
#   for_each = toset(data.aws_subnets.default_subnet.ids)
#   id       = each.value
# }

# data "aws_lb_target_group" "existing_tg" {
#   name = var.tgName
# }

# resource "aws_autoscaling_group" "example" {
#   name                 = var.asgName
#   launch_template {
#     id      = data.aws_launch_template.example.id
#     version = var.launchTempVersion
#   }
#   min_size             = 1
#   max_size             = 4
#   desired_capacity     = 1
#   vpc_zone_identifier = [for s in data.aws_subnet.selected_default_subnet : s.id]

#   health_check_type          = "EC2"
#   health_check_grace_period  = 300
#   default_cooldown           = 300
#   force_delete               = true  # This flag will cause instances to be terminated during a scale-in event, even if they haven't been marked for termination by the Auto Scaling group.

#   tag {
#     key                 = "Name"
#     value               = var.tagNameInstance
#     propagate_at_launch = true
#   }

#   target_group_arns = [data.aws_lb_target_group.existing_tg.arn]

# }


# AUTO SCALING GROUP 2
data "aws_elb" "existing_clb" {
  name = var.clbName
}

resource "aws_autoscaling_group" "example" {
  name                 = var.asgName
  launch_template {
    id      = data.aws_launch_template.example.id
    version = var.launchTempVersion
  }
  min_size             = 1
  max_size             = 4
  desired_capacity     = 1

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  default_cooldown           = 300
  force_delete               = true  # This flag will cause instances to be terminated during a scale-in event, even if they haven't been marked for termination by the Auto Scaling group.

  load_balancers = [data.aws_elb.existing_clb.name]
}