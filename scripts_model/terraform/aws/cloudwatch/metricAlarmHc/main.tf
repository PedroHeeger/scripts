# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "metric_alarm_name" {
  description = "Nome do alarme de métrica"
  type        = string
  default     = "healthCheckMetricAlarm1"
}

variable "metric_alarm_description" {
  description = "Descrição do alarme de métrica"
  type        = string
  default     = "metricAlarmDescription1"
}

variable "metric_name" {
  description = "Nome da métrica"
  type        = string
  default     = "HealthCheckStatus"
}

variable "namespace" {
  description = "Namespace da métrica"
  type        = string
  default     = "AWS/Route53"
}

variable "statistic" {
  description = "Estatística para o alarme"
  type        = string
  default     = "Average"
}

variable "period" {
  description = "Período em segundos para a métrica"
  type        = number
  default     = 60
}

variable "threshold" {
  description = "Limite para o alarme"
  type        = number
  default     = 1
}

variable "comparison_operator" {
  description = "Operador de comparação para o alarme"
  type        = string
  default     = "LessThanThreshold"
}

variable "evaluation_periods" {
  description = "Períodos de avaliação para o alarme"
  type        = number
  default     = 1
}

variable "health_check_name" {
  description = "Nome da verificação de integridade"
  type        = string
  default     = "healthCheckTest5"
}

variable "health_check_id" {
  description = "ID da verificação de integridade"
  type        = string
  default     = "3e624507-3557-4ba9-bc50-eeff0645d740"
}

variable "topic_name" {
  description = "Nome do tópico SNS"
  type        = string
  default     = "topicTest1"
}



# Executando o código
provider "aws" {
  region = var.region
}

# TÓPICO SNS
data "aws_sns_topic" "example" {
  name = var.topic_name
}

# MÉTRICA ALARM
resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name                = var.metric_alarm_name
  alarm_description         = var.metric_alarm_description
  metric_name               = var.metric_name
  namespace                 = var.namespace
  statistic                 = var.statistic
  period                    = var.period
  threshold                 = var.threshold
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  dimensions                = {
    HealthCheckId = var.health_check_id  # Infelizmente não há um recurso do tipo aws_route53_health_check para consulta de dados no Terraform, portanto teve que usar o ID.
  }
  alarm_actions             = [data.aws_sns_topic.example.arn]
  ok_actions                = [data.aws_sns_topic.example.arn]
}



# Outputs
output "alarm_name" {
  description = "Nome do alarme de métrica criado"
  value       = aws_cloudwatch_metric_alarm.example.alarm_name
}

output "alarm_arn" {
  description = "ARN do alarme de métrica criado"
  value       = aws_cloudwatch_metric_alarm.example.arn
}