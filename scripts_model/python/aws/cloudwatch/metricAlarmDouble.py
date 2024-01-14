#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("METRIC ALARM DOUBLE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
metric_alarm_name1 = "metricAlarm1"
metric_alarm_name2 = "metricAlarm2"
metric_alarm_description = "metricAlarmDescription"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
statistic = "Average"
threshold1 = 70
threshold2 = 40
comparison_operator1 = "GreaterThanThreshold"
comparison_operator2 = "LessThanThreshold"
asg_name = "asgTest1"
# ass_scaling_policy_name = "assScalingPolicy1"    # STEP SCALING POLICY
as_scaling_policy_name1 = "asScalingPolicy1"    # SIMPLE SCALING POLICY
as_scaling_policy_name2 = "asScalingPolicy2"    # SIMPLE SCALING POLICY

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço CloudWatch e outro para o Auto Scaling")
    cloudwatch_client = boto3.client('cloudwatch')
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe os metric alarms de nomes {metric_alarm_name1} e {metric_alarm_name2}")
    alarms = cloudwatch_client.describe_alarms(
        AlarmNames=[metric_alarm_name1, metric_alarm_name2]
    )['MetricAlarms']

    if alarms:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe um dos metric alarms de nomes {metric_alarm_name1} e {metric_alarm_name2}")
        for alarm in alarms:
            print(alarm['AlarmName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os metric alarms existentes")
        all_alarms = cloudwatch_client.describe_alarms()['MetricAlarms']
        for alarm in all_alarms:
            print(alarm['AlarmName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da scaling policy do grupo de auto scaling {asg_name}")
        # arn_scaling_policy = autoscaling_client.describe_policies(AutoScalingGroupName=asg_name, PolicyNames=[ass_scaling_policy_name])['ScalingPolicies'][0]['PolicyARN']
        arn_scaling_policy1 = autoscaling_client.describe_policies(AutoScalingGroupName=asg_name, PolicyNames=[as_scaling_policy_name1])['ScalingPolicies'][0]['PolicyARN']
        arn_scaling_policy2 = autoscaling_client.describe_policies(AutoScalingGroupName=asg_name, PolicyNames=[as_scaling_policy_name2])['ScalingPolicies'][0]['PolicyARN']

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando o metric alarm de nome {metric_alarm_name1}")
        # cloudwatch_client.put_metric_alarm(
        #     AlarmName=metric_alarm_name1,
        #     AlarmDescription=metric_alarm_description,
        #     MetricName=metric_name,
        #     Namespace=namespace,
        #     Statistic=statistic,
        #     Period=300,
        #     Threshold=threshold1,
        #     ComparisonOperator=comparison_operator1,
        #     Unit='Percent',
        #     EvaluationPeriods=2,
        #     ActionsEnabled=True,
        #     Dimensions=[{'Name': 'AutoScalingGroupName', 'Value': asg_name}],
        #     AlarmActions=[arn_scaling_policy]
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o metric alarm de nome {metric_alarm_name1}")
        cloudwatch_client.put_metric_alarm(
            AlarmName=metric_alarm_name1,
            AlarmDescription=metric_alarm_description,
            MetricName=metric_name,
            Namespace=namespace,
            Statistic=statistic,
            Period=300,
            Threshold=threshold1,
            ComparisonOperator=comparison_operator1,
            Unit='Percent',
            EvaluationPeriods=2,
            ActionsEnabled=True,
            Dimensions=[{'Name': 'AutoScalingGroupName', 'Value': asg_name}],
            AlarmActions=[arn_scaling_policy1]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o metric alarm de nome {metric_alarm_name2}")
        cloudwatch_client.put_metric_alarm(
            AlarmName=metric_alarm_name2,
            AlarmDescription=metric_alarm_description,
            MetricName=metric_name,
            Namespace=namespace,
            Statistic=statistic,
            Period=300,
            Threshold=threshold2,
            ComparisonOperator=comparison_operator2,
            Unit='Percent',
            EvaluationPeriods=2,
            ActionsEnabled=True,
            Dimensions=[{'Name': 'AutoScalingGroupName', 'Value': asg_name}],
            AlarmActions=[arn_scaling_policy2]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando os metric alarms de nomes {metric_alarm_name1} e {metric_alarm_name2}")
        alarms_after_creation = cloudwatch_client.describe_alarms(AlarmNames=[metric_alarm_name1, metric_alarm_name2])['MetricAlarms']
        for alarm in alarms_after_creation:
            print(alarm['AlarmName'])
else:
    print("Código não executado")


#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("METRIC ALARM DOUBLE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
metric_alarm_name1 = "metricAlarm1"
metric_alarm_name2 = "metricAlarm2"



print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço CloudWatch")
    cloudwatch_client = boto3.client('cloudwatch')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe os metric alarms de nomes {metric_alarm_name1} e {metric_alarm_name2}")
    alarms = cloudwatch_client.describe_alarms(
        AlarmNames=[metric_alarm_name1, metric_alarm_name2]
    )['MetricAlarms']

    if alarms:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os metric alarms existentes")
        all_alarms = cloudwatch_client.describe_alarms()['MetricAlarms']
        for alarm in all_alarms:
            print(alarm['AlarmName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo os metric alarms de nomes {metric_alarm_name1} e {metric_alarm_name2}")
        cloudwatch_client.delete_alarms(AlarmNames=[metric_alarm_name1, metric_alarm_name2])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os metric alarms existentes")
        alarms_after_deletion = cloudwatch_client.describe_alarms()['MetricAlarms']
        for alarm in alarms_after_deletion:
            print(alarm['AlarmName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Não existe um dos metric alarms de nomes {metric_alarm_name1} e {metric_alarm_name2}")
else:
    print("Código não executado")