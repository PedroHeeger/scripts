# Definindo Variáveis
variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "asgName" {
  description = "Nome do Auto Scaling Group"
  default     = "asgTest1"
}

variable "asttScalingPolicyName" {
  description = "Nome da Target Tracking Scaling Policy"
  default     = "asttScalingPolicy1"
}

variable "asScalingPolicyName1" {
  description = "Nome da Simple Scaling Policy"
  default     = "asScalingPolicy1"
}

variable "asScalingPolicyName2" {
  description = "Nome da Simple Scaling Policy"
  default     = "asScalingPolicy2"
}

variable "assScalingPolicyName" {
  description = "Nome da Step Scaling Policy"
  default     = "assScalingPolicy1"
}


variable "metricAlarmName1" {
  description = "Nome do alarme de métrica 1"
  default     = "metricAlarm1"
}

variable "metricAlarmName2" {
  description = "Nome do alarme de métrica 2"
  default     = "metricAlarm2"
}

variable "metricAlarmDescription" {
  description = "Descrição do alarme de métrica"
  default     = "metricAlarmDescription"
}

variable "metricName" {
  description = "Nome da métrica"
  default     = "CPUUtilization"
}

variable "namespace" {
  description = "Namespace da métrica"
  default     = "AWS/EC2"
}

variable "statistic" {
  description = "Estátistica da métrica"
  default     = "Average"
}

variable "threshold1" {
  description = "Limiar do alarme 1"
  default     = 70
}

variable "threshold2" {
  description = "Limiar do alarme 2"
  default     = 40
}

variable "comparisonOperator1" {
  description = "Operador de comparação 1"
  default     = "GreaterThanThreshold"
}

variable "comparisonOperator2" {
  description = "Operador de comparação 2"
  default     = "LessThanThreshold"
}



# Executando o código
provider "aws" {
  region = var.region
}

# TARGET TRACKING SCALING POLICY
resource "aws_autoscaling_policy" "exemplo_policy" {
  name                   = var.asttScalingPolicyName
  autoscaling_group_name = var.asgName
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
    disable_scale_in = false
  }
}



# SIMPLE SCALING POLICY
# resource "aws_autoscaling_policy" "simple_scaling_policy1" {
#   name                   = var.asScalingPolicyName1
#   scaling_adjustment    = 1
#   adjustment_type       = "ChangeInCapacity"
#   cooldown              = 300
#   autoscaling_group_name = var.asgName
# }

# resource "aws_autoscaling_policy" "simple_scaling_policy2" {
#   name                   = var.asScalingPolicyName2
#   scaling_adjustment    = -1
#   adjustment_type       = "ChangeInCapacity"
#   cooldown              = 300
#   autoscaling_group_name = var.asgName
# }

# resource "aws_cloudwatch_metric_alarm" "example1" {
#   alarm_name          = var.metricAlarmName1
#   alarm_description   = var.metricAlarmDescription
#   metric_name         = var.metricName
#   namespace           = var.namespace
#   statistic           = var.statistic
#   period              = 300
#   threshold           = var.threshold1
#   comparison_operator = var.comparisonOperator1
#   unit                = "Percent"
#   evaluation_periods  = 2
#   actions_enabled     = true

#   dimensions = {
#     AutoScalingGroupName = var.asgName
#   }

#   alarm_actions = [resource.aws_autoscaling_policy.simple_scaling_policy1.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "example2" {
#   alarm_name          = var.metricAlarmName2
#   alarm_description   = var.metricAlarmDescription
#   metric_name         = var.metricName
#   namespace           = var.namespace
#   statistic           = var.statistic
#   period              = 300
#   threshold           = var.threshold2
#   comparison_operator = var.comparisonOperator2
#   unit                = "Percent"
#   evaluation_periods  = 2
#   actions_enabled     = true

#   dimensions = {
#     AutoScalingGroupName = var.asgName
#   }

#   alarm_actions = [resource.aws_autoscaling_policy.simple_scaling_policy2.arn]
# }



# STEP SCALING POLICY
# resource "aws_autoscaling_policy" "step_scaling_policy" {
#   name                   = var.assScalingPolicyName
#   adjustment_type        = "ChangeInCapacity"
#   autoscaling_group_name = var.asgName
#   policy_type            = "StepScaling"

#   step_adjustment {
#     metric_interval_lower_bound = 0.0
#     metric_interval_upper_bound = 40.0
#     scaling_adjustment         = 0
#   }

#   step_adjustment {
#     metric_interval_lower_bound = 40.0
#     metric_interval_upper_bound = 90.0
#     scaling_adjustment         = 1
#   }

#   step_adjustment {
#     metric_interval_lower_bound = 90.0
#     scaling_adjustment         = 2
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "example1" {
#   alarm_name          = var.metricAlarmName1
#   alarm_description   = var.metricAlarmDescription
#   metric_name         = var.metricName
#   namespace           = var.namespace
#   statistic           = var.statistic
#   period              = 300
#   threshold           = var.threshold1
#   comparison_operator = var.comparisonOperator1
#   unit                = "Percent"
#   evaluation_periods  = 2
#   actions_enabled     = true

#   dimensions = {
#     AutoScalingGroupName = var.asgName
#   }

#   alarm_actions = [resource.aws_autoscaling_policy.step_scaling_policy.arn]
# }