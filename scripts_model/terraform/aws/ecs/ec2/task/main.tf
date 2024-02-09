# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

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
  default        = "docker.io/fabricioveronez/conversao-temperatura:latest"
}

variable "containerName2" {
  description = "Nome do segundo contêiner na tarefa ECS"
  default        = "containerTest2"
}

variable "dockerImage2" {
  description = "Imagem Docker para o segundo contêiner"
  default        = "public.ecr.aws/nginx/nginx"
}

variable "logGroupName" {
  description = "Nome do grupo CloudWatch Logs"
  default        = "/aws/ecs/ec2/taskEc2Test1"
}


# Executando o código
provider "aws" {
  region = var.region
}

data "aws_iam_role" "example" {
  name = var.executionRoleName
}

resource "aws_ecs_task_definition" "example" {
  family                   = var.taskName
  network_mode             = "bridge"
  requires_compatibilities = [var.launchType]

  execution_role_arn = data.aws_iam_role.example.arn

  container_definitions = jsonencode([
    {
      name  = var.containerName1
      image = var.dockerImage1
      cpu   = 128
      memory = 256
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ],
      essential = false,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = var.logGroupName
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = var.containerName1
        }
      }
    },
    {
      name  = var.containerName2
      image = var.dockerImage2
      cpu   = 128
      memory = 256
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = var.logGroupName
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = var.containerName2
        }
      }
    }
  ])
}