# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}


## PARTE 1
# ROLE 1
variable "roleName1" {
  description = "Nome da role"
  default     = "ecsTaskExecutionRole"
}

# POLICY 1
variable "policyName1" {
  description = "Nome da policy"
  default     = "AmazonECSTaskExecutionRolePolicy"
}

variable "serviceName1" {
  description = "Nome do serviço (principal)"
  default     = "ecs-tasks.amazonaws.com"
}

# LOG GROUP
variable "logGroupName" {
  description = "Nome do grupo de log do Amazon CloudWatch"
  default     = "/aws/ecs/ec2/taskEc2Test1"
}



## PARTE 2
# ROLE 2
variable "roleName2" {
  description = "Nome da role"
  default     = "ecs-ec2InstanceRole"
}

# POLICY 2
variable "policyName2" {
  description = "Nome da policy"
  default     = "AmazonECS_FullAccess"
}

variable "serviceName2" {
  description = "Nome do serviço (principal)"
  default     = "ec2.amazonaws.com"
}

# INSTANCE PROFILE 2
variable "instanceProfileName2" {
  description = "Nome do perfil de instância"
  default     = "instanceProfileTest"
}



## PARTE 3
# ALB
variable "lbName" {
  description = "Nome do Application Load Balancer"
  default     = "lbTest1"
}

variable "aZ1" {
  description = "Nome da zona de disponibilidade 1"
  default     = "us-east-1a"
}

variable "aZ2" {
  description = "Nome da zona de disponibilidade 2"
  default     = "us-east-1b"
}

# TARGET GROUP
variable "tgName" {
  description = "Nome do Target Group"
  default     = "tgTest1"
}

variable "tgType" {
  description = "Tipo de Target Group"
  default     = "instance"
#   default     = "ip"
}

variable "tgProtocol" {
  description = "Protocolo de Rede"
  default     = "HTTP"
}

variable "tgProtocolVersion" {
  description = "Versão do Protocolo de Rede"
  default     = "HTTP1"
}

variable "tgPort" {
  description = "Porta"
  default     = "80"
}

variable "tgHealthCheckProtocol" {
  description = "Protocolo da verificação de integridade"
  default     = "HTTP"
}

variable "tgHealthCheckPort" {
  description = "Porta da verificação de integridade"
  default     = "traffic-port"
}

variable "tgHealthCheckPath" {
  description = "Path da verificação de integridade"
  default     = "/"
}

# LISTENER
variable "listenerProtocol1" {
  description = "Protocolo do Listener"
  default     = "HTTP"
}

variable "listenerPort1" {
  description = "Porta do Listener"
  default     = 80
}



## PARTE 4
# LAUNCH TEMPLATE
variable "launchTempName" {
  description = "Nome do Launch Template"
  default     = "launchTempTest1"
}

variable "versionDescription" {
  description = "Descrição da versão do Launch Template"
  default     = "My version 1"
}

variable "tagNameInstance" {
  description = "Nome da tag da instância"
  default     = "ec2Test"
}

variable "imageId" {
  description = "Imagem Id da instância"
  default     = "ami-0f90bd3669358d247"            # al2023-ami-ecs-hvm-2023.0.20240201-kernel-6.1-x86_64
}

variable "instanceType" {
  description = "Tipo da instância"
  default     = "t2.micro"
}

variable "keyPairName" {
  description = "Nome do par de chaves"
  default     = "keyPairUniversal"
}

variable "deviceName" {
  description = "Nome do Dispositivo de Armazenamento"
  default     = "/dev/xvda"
}

variable "volumeSize" {
  description = "Tamanho do Volume de Armazenamento"
  default     = 30
}

variable "volumeType" {
  description = "Tipo do Volume de Armazenamento"
  default     = "gp2"
}

variable "userDataPath" {
  description = "Caminho para o arquivo user data"
  default     = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/httpd_stress"
}

variable "userDataFile" {
  description = "Arquivo user data"
  default     = "udFileBase64.txt"
}

# AUTO SCALING GROUP
variable "asgName" {
  description = "Nome do Auto Scaling Group"
  default     = "asgTest1"
}

variable "launchTempVersion" {
  description = "Versão do Launch Template"
  default     = 1
}



## PARTE 5
# RDS
variable "dbInstanceName" {
  description = "Nome da instância de banco de dados"
  default     = "db-instance-test1"
}

variable "dbInstanceClass" {
  description = "Classe da instância de banco de dados"
  default     = "db.t3.micro"
}

variable "engine" {
  description = "Tipo de banco de dados"
  default     = "postgres"
}

variable "engineversion" {
  description = "Versão do banco de dados"
  default     = "16.1"
}

variable "masterUsername" {
  description = "Nome de usuário do mestre"
  default     = "masterUsernameTest1"
}

variable "masterPassword" {
  description = "Senha do mestre"
  default     = "masterPasswordTest1"
}

variable "allocatedStorage" {
  description = "Armazenamento alocado em GB"
  default     = 20
}

variable "storageType" {
  description = "Tipo de armazenamento"
  default     = "gp2"
}

variable "dbName" {
  description = "Nome do banco de dados"
  default     = "dbTest1"
}

variable "periodBackup" {
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



## PARTE 6
# CAPACITY PROVIDER
variable "capacityProviderName" {
  description = "Nome do fornecedor de capacidade"
  default     = "capacityProviderTest1"
}

# CLUSTER
variable "clusterName" {
  description = "Nome da cluster"
  default     = "clusterEC2Test1"
}

# TASK DEFINITION
variable "taskName" {
  description = "Nome da tarefa ECS"
  default        = "taskEC2Test1"
}

variable "executionRoleName" {
  description = "Nome da função de execução da tarefa ECS"
  default        = "ecsTaskExecutionRole"
}

variable "launchType" {
  description = "Tipo de lançamento para a tarefa ECS"
  default        = "EC2"
}

variable "containerName1" {
  description = "Nome do primeiro contêiner na tarefa ECS"
  default        = "containerTest1"
}

variable "dockerImage1" {
  description = "A imagem Docker para o primeiro contêiner"
  default        = "docker.io/pedroheeger/curso116_kube-news:v2"
}

variable "containerName2" {
  description = "Nome do segundo contêiner na tarefa ECS"
  default        = "containerTest2"
}

variable "dockerImage2" {
  description = "Imagem Docker para o segundo contêiner"
  default        = "public.ecr.aws/nginx/nginx"
}

# SERVICE
variable "serviceName" {
  description = "Nome do serviço ECS"
  default     = "svcEC2Test1"
}

variable "taskDefinitionFamily" {
  description = "Família da definição de tarefa ECS"
  default     = "taskEC2Test1"
}

variable "taskDefinitionRevision" {
  description = "Revisão da definição de tarefa ECS"
  default     = "15"
}

variable "taskCount" {
  description = "Número desejado de tarefas ECS em execução"
  default     = 2
}

variable "containerPort1" {
  description = "Porta do primeiro contêiner na definição de tarefa ECS"
  default     = 8080
}



## PARTE 7
# HOSTED ZONE
variable "hostedZoneName" {
  description = "Nome da Zona de Hospedagem"
  default = "pedroheeger.dev.br."
}

variable "domainName" {
  description = "Nome de Domínio"
  default = "pedroheeger.dev.br"
}

variable "hostedZoneComment" {
  description = "Comentário da Zona de Hospedagem"
  default = "hostedZoneCommentTest4"
}



## PARTE 8
# RECORD
variable "resourceRecordName" {
  description = "Nome do registro CNAME a ser criado"
  default     = "recordNameLbTest1"
}

# LISTENER
variable "listenerProtocol2" {
  description = "Protocolo do Listener"
  default     = "HTTPS"
}

variable "listenerPort2" {
  description = "Porta do Listener"
  default     = "443"
}



# Executando o código
provider "aws" {
  region = var.region
}

# REDE
data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_security_group" "default" {
  name        = "default"
  vpc_id      = data.aws_vpcs.default.ids[0]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default.ids[0]]
  }

  filter {
    name   = "availability-zone"
    values = [var.aZ1, var.aZ2]
  }
}

data "aws_subnet" "selected_default_subnet" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# output "subnet_ids" {
#   value = [for s in data.aws_subnet.selected_default_subnet : s.id]
# }



## PARTE 1 - Role de permissão para execução de task no cluster
# ROLE 1
resource "aws_iam_role" "example1" {
  name = var.roleName1

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = var.serviceName1
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# POLICY 1
data "aws_iam_policy" "example1" {
  name = var.policyName1
}

resource "aws_iam_role_policy_attachment" "example1" {
  policy_arn = data.aws_iam_policy.example1.arn
  role       = aws_iam_role.example1.name
}

# LOG GROUP
resource "aws_cloudwatch_log_group" "example" {
  name = var.logGroupName

  retention_in_days = 30  # Define a retenção em dias para os logs, ajuste conforme necessário
}



## PARTE 2 - Role para as instâncias do EC2 entrarem no cluster
# ROLE 2
resource "aws_iam_role" "example2" {
  name = var.roleName2

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = var.serviceName2
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# POLICY 2
data "aws_iam_policy" "example2" {
  name        = var.policyName2
}

resource "aws_iam_role_policy_attachment" "example2" {
  policy_arn = data.aws_iam_policy.example2.arn
  role       = aws_iam_role.example2.name
}

# INSTANCE PROFILE 2
resource "aws_iam_instance_profile" "example2" {
  name = var.instanceProfileName2
  role = var.roleName2
}



## PARTE 3 - ALB
# ALB
resource "aws_lb" "example" {
  name               = var.lbName
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.default.id]
  subnets            = [for s in data.aws_subnet.selected_default_subnet : s.id]

  enable_deletion_protection = false // Define como true se você deseja proteção contra exclusão
}

# TARGET GROUP
resource "aws_lb_target_group" "example" {
  name        = var.tgName
  port        = var.tgPort
  protocol    = var.tgProtocol
  target_type = var.tgType
  protocol_version = var.tgProtocolVersion
  vpc_id      = data.aws_vpcs.default.ids[0]
  
  health_check {
    enabled             = true
    interval            = 15
    path                = var.tgHealthCheckPath
    port                = var.tgHealthCheckPort
    protocol            = var.tgHealthCheckProtocol
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# LISTENER 1
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.listenerPort1
  protocol          = var.listenerProtocol1

  # default_action {
  #   type             = "fixed-response"
  #   fixed_response {
  #     content_type = "text/plain"
  #     status_code  = "200"
  #     message_body = "OK"
  #   }
  # }

  dynamic "default_action" {
    for_each = aws_lb_target_group.example.arn != null ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.example.arn
    }
  }
}



## PARTE 4 - Auto Scaling Group
# Launch Template
resource "aws_launch_template" "example" {
  name = var.launchTempName
  description = var.versionDescription
  image_id        = var.imageId
  instance_type   = var.instanceType
  key_name        = var.keyPairName
  vpc_security_group_ids = [data.aws_security_group.default.id]

  block_device_mappings {
    device_name = var.deviceName

    ebs {
      volume_size = var.volumeSize
      volume_type = var.volumeType
    }
  }

  iam_instance_profile {
    name = var.instanceProfileName2
  }

  user_data = base64encode(
    <<-EOF
      #!/bin/bash
      echo "ECS_CLUSTER=${var.clusterName}" | sudo tee -a /etc/ecs/ecs.config
    EOF
  )
}

# AUTO SCALING GROUP
resource "aws_autoscaling_group" "example" {
  name                 = var.asgName
  launch_template {
    id      = aws_launch_template.example.id
    version = var.launchTempVersion
  }
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier = [for s in data.aws_subnet.selected_default_subnet : s.id]

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  default_cooldown           = 300
  force_delete               = true  # This flag will cause instances to be terminated during a scale-in event, even if they haven't been marked for termination by the Auto Scaling group.

  tag {
    key                 = "Name"
    value               = var.tagNameInstance
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.example.arn]
}



## PARTE 5 - RDS
resource "aws_db_instance" "example" {
  identifier              = var.dbInstanceName
  instance_class          = var.dbInstanceClass
  engine                  = var.engine
  engine_version          = var.engineversion
  db_name                 = var.dbName
  username                = var.masterUsername
  password                = var.masterPassword
  allocated_storage       = var.allocatedStorage
  storage_type            = var.storageType
  vpc_security_group_ids = [data.aws_security_group.default.id]
  availability_zone       = var.aZ1
  backup_retention_period = var.periodBackup
  skip_final_snapshot     = true
}



## PARTE 6 - ECS
# CAPACITY PROVIDER
resource "aws_ecs_capacity_provider" "example" {
  name = var.capacityProviderName

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example.arn
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
    managed_termination_protection = "DISABLED"
  }
}

# CLUSTER
resource "aws_ecs_cluster" "example" {
  name = var.clusterName
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# resource "aws_ecs_cluster_capacity_providers" "example" {
#   cluster_name = aws_ecs_cluster.example.name

#   capacity_providers = [aws_ecs_capacity_provider.example.name]

#   default_capacity_provider_strategy {
#     base              = 1
#     weight            = 100
#     capacity_provider = "EC2"
#   }
# }

# TASK DEFINITION
resource "aws_ecs_task_definition" "example" {
  family                   = var.taskName
  network_mode             = "bridge"
  requires_compatibilities = [var.launchType]

  execution_role_arn = aws_iam_role.example1.arn

  container_definitions = jsonencode([
    {
      name  = var.containerName1
      image = var.dockerImage1
      cpu   = 256
      memory = 512
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 80
        }
      ],
      essential = true,
      environment = [
          {name = "DB_DATABASE", value = "kubenews"},
          {name = "DB_USERNAME", value = "kubenews"},
          {name = "DB_PASSWORD", value = "Pg#123"},
          {name = "DB_HOST", value = aws_db_instance.example.endpoint}
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = var.logGroupName
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = var.containerName1
        }
      }
    }
  ])
}

resource "null_resource" "remove_old_task_definition" {
  provisioner "local-exec" {
    command = "aws ecs delete-task-definitions --task-definition ${aws_ecs_task_definition.example.family}:${aws_ecs_task_definition.example.revision}"
  }
}

# SERVICE
resource "aws_ecs_service" "example" {
  name            = var.serviceName
  cluster         = var.clusterName
  # task_definition = "${var.taskDefinitionFamily}:${var.taskDefinitionRevision}"
  task_definition = "${aws_ecs_task_definition.example.family}:${aws_ecs_task_definition.example.revision}"

  desired_count = var.taskCount

  launch_type             = var.launchType
  scheduling_strategy     = "REPLICA"
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 25

  load_balancer {
  target_group_arn = aws_lb_target_group.example.arn
  container_name   = var.containerName1
  container_port   = var.containerPort1
  }
}



# ## PARTE 7 - DOMAIN
# # HOSTED ZONE
# data "aws_route53_zone" "example" {
#   name              = var.hostedZoneName
#   # comment           = var.hostedZoneComment
# }

# # ACM
# resource "aws_acm_certificate" "example" {
#   domain_name       = var.domainName
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "example" {
#   for_each = {
#     for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 300
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.example.zone_id
# }

# # resource "aws_acm_certificate_validation" "example" {
# #   certificate_arn         = aws_acm_certificate.example.arn
# #   validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
# # }



# ## PARTE 8 - HTTPS
# # RECORD
# resource "aws_route53_record" "record" {
#   zone_id = data.aws_route53_zone.example.zone_id
#   name    = var.resourceRecordName
#   type    = "CNAME"
#   ttl     = 300
#   records = [aws_lb.example.dns_name]
# }

# # LISTENER 2
# resource "aws_lb_listener" "example2" {
#   load_balancer_arn = aws_lb.example.arn
#   port              = var.listenerPort2
#   protocol          = var.listenerProtocol2

#   # default_action {
#   #   type             = "fixed-response"
#   #   fixed_response {
#   #     content_type = "text/plain"
#   #     status_code  = "200"
#   #     message_body = "OK"
#   #   }
#   # }

#   dynamic "default_action" {
#     for_each = aws_lb_target_group.example.arn != null ? [1] : []
#     content {
#       type             = "forward"
#       target_group_arn = aws_lb_target_group.example.arn
#     }
#   }

#   # ssl_policy            = "ELBSecurityPolicy-2016-08"
#   certificate_arn       = aws_acm_certificate.example.arn
# }









# Saída
output "aws_lb" {
  value = aws_lb.example.dns_name
}