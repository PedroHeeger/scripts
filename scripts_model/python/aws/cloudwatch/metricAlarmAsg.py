#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("METRIC ALARM ASG CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
metric_alarm_name = "asgMetricAlarm1"
metric_alarm_description = "asgMetricAlarmDescription1"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
statistic = "Average"      # Se a média dos resultados da métrica em 2 períodos no intervalo de tempo de 300 segundos for maior que o limite de 70%, o alarme é acionado
period = 300
threshold = 70
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2

resource_key = "AutoScalingGroupName"
asg_name = "asgTest1"
as_scaling_policy_name = "asScalingPolicy1"  # SIMPLE SCALING POLICY
# as_scaling_policy_name = "assScalingPolicy1"  # STEP SCALING POLICY

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço CloudWatch e outro para o Auto Scaling")
    cloudwatch_client = boto3.client('cloudwatch')
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o metric alarm de nome {metric_alarm_name}")
    alarms = cloudwatch_client.describe_alarms(
        AlarmNames=[metric_alarm_name]
    )['MetricAlarms']

    if alarms:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o metric alarm de nome {metric_alarm_name}")
        print(alarms[0]['AlarmName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os metric alarms existentes")
        all_alarms = cloudwatch_client.describe_alarms()['MetricAlarms']
        for alarm in all_alarms:
            print(alarm['AlarmName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da scaling policy simples do grupo de auto scaling {asg_name}")
        arn_scaling_policy = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyNames=[as_scaling_policy_name]
        )['ScalingPolicies'][0]['PolicyARN']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o metric alarm de nome {metric_alarm_name}")
        cloudwatch_client.put_metric_alarm(
            AlarmName=metric_alarm_name,
            AlarmDescription=metric_alarm_description,
            MetricName=metric_name,
            Namespace=namespace,
            Statistic=statistic,
            Period=period,
            Threshold=threshold,
            ComparisonOperator=comparison_operator,
            EvaluationPeriods=evaluation_periods,
            Dimensions=[{'Name': resource_key, 'Value': asg_name}],
            AlarmActions=[arn_scaling_policy]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o metric alarm de nome {metric_alarm_name}")
        alarms_after_creation = cloudwatch_client.describe_alarms(
            AlarmNames=[metric_alarm_name]
        )['MetricAlarms']
        print(alarms_after_creation[0]['AlarmName'])
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("METRIC ALARM ASG EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
metric_alarm_name = "asgMetricAlarm1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço CloudWatch")
    cloudwatch_client = boto3.client('cloudwatch')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o metric alarm de nome {metric_alarm_name}")
    alarms = cloudwatch_client.describe_alarms(
        AlarmNames=[metric_alarm_name]
    )['MetricAlarms']

    if alarms:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os metric alarms existentes")
        all_alarms = cloudwatch_client.describe_alarms()['MetricAlarms']
        for alarm in all_alarms:
            print(alarm['AlarmName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o metric alarm de nome {metric_alarm_name}")
        cloudwatch_client.delete_alarms(
            AlarmNames=[metric_alarm_name]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os metric alarms existentes")
        alarms_after_removal = cloudwatch_client.describe_alarms()['MetricAlarms']
        for alarm in alarms_after_removal:
            print(alarm['AlarmName'])
    else:
        print(f"Não existe o metric alarm de nome {metric_alarm_name}")
else:
    print("Código não executado")