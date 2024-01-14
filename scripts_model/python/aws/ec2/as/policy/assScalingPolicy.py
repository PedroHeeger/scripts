#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("STEP SCALING POLICY CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
ass_scaling_policy_name = "assScalingPolicy1"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a step scaling policy de nome {ass_scaling_policy_name} no auto scaling group {asg_name}")
    scaling_policies = autoscaling_client.describe_policies(
        AutoScalingGroupName=asg_name,
        PolicyNames=[ass_scaling_policy_name]
    )['ScalingPolicies']

    if scaling_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a step scaling policy de nome {ass_scaling_policy_name} no auto scaling group {asg_name}")
        for policy in scaling_policies:
            print(policy['PolicyName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as step scaling policies do auto scaling group {asg_name}")
        scaling_policy_names = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyTypes=['StepScaling']
        )['ScalingPolicies']
        for policy in scaling_policy_names:
            print(policy['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a step scaling policy de nome {ass_scaling_policy_name} no auto scaling group {asg_name}")
        autoscaling_client.put_scaling_policy(
            PolicyName=ass_scaling_policy_name,
            AutoScalingGroupName=asg_name,
            PolicyType='StepScaling',
            AdjustmentType='ChangeInCapacity',
            Cooldown=300,
            StepAdjustments=[
                {
                    'MetricIntervalLowerBound': 0.0,
                    'MetricIntervalUpperBound': 40.0,
                    'ScalingAdjustment': 0
                },
                {
                    'MetricIntervalLowerBound': 40.0,
                    'MetricIntervalUpperBound': 90.0,
                    'ScalingAdjustment': 1
                },
                {
                    'MetricIntervalLowerBound': 90.0,
                    'ScalingAdjustment': 2
                }
            ]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a step scaling policy de nome {ass_scaling_policy_name} no auto scaling group {asg_name}")
        scaling_policy_names = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyNames=[ass_scaling_policy_name]
        )['ScalingPolicies']
        for policy in scaling_policy_names:
            print(policy['PolicyName'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("STEP SCALING POLICY EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
ass_scaling_policy_name = "assScalingPolicy1"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a step scaling policy de nome {ass_scaling_policy_name} no auto scaling group {asg_name}")
    scaling_policies = autoscaling_client.describe_policies(
        AutoScalingGroupName=asg_name,
        PolicyNames=[ass_scaling_policy_name],
        PolicyTypes=['StepScaling']
    )['ScalingPolicies']

    if scaling_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as step scaling policies do auto scaling group {asg_name}")
        for policy in scaling_policies:
            print(policy['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a step scaling policy de nome {ass_scaling_policy_name} no auto scaling group {asg_name}")
        autoscaling_client.delete_policy(
            AutoScalingGroupName=asg_name,
            PolicyName=ass_scaling_policy_name
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as step scaling policies do auto scaling group {asg_name}")
        scaling_policy_names = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyTypes=['StepScaling']
        )['ScalingPolicies']
        for policy in scaling_policy_names:
            print(policy['PolicyName'])
    else:
        print(f"Não existe a step scaling policy de nome {ass_scaling_policy_name} no auto scaling group {asg_name}")
else:
    print("Código não executado")