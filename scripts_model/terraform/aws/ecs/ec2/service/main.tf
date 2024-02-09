# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "serviceName" {
  description = "Nome do serviço ECS"
  default     = "svcEC2Test1"
}

variable "clusterName" {
  description = "Nome do cluster ECS"
  default     = "clusterEC2Test1"
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

variable "launchType" {
  description = "Tipo de Implantação"
  default     = "EC2"
}

variable "tgName" {
  description = "Nome do grupo de destinos ECS"
  default     = "tgTest1"
}

variable "containerName1" {
  description = "Nome do primeiro contêiner na definição de tarefa ECS"
  default     = "containerTest1"
}

variable "containerPort1" {
  description = "Porta do primeiro contêiner na definição de tarefa ECS"
  default     = 8080
}



# Executando o código
provider "aws" {
  region = var.region
}

# data "aws_lb_target_group" "example" {
#   name = var.tgName
# }

resource "aws_ecs_service" "example" {
  name            = var.serviceName
  cluster         = var.clusterName
  task_definition = "${var.taskDefinitionFamily}:${var.taskDefinitionRevision}"

  desired_count = var.taskCount

  launch_type             = var.launchType
  scheduling_strategy     = "REPLICA"
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 25

#   load_balancer {
#   target_group_arn = data.aws_lb_target_group.example.arn
#   container_name   = var.containerName1
#   container_port   = var.containerPort1
#   }
}