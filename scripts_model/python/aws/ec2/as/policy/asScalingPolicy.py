#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("SIMPLE SCALING POLICY CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
as_scaling_policy_name = "asScalingPolicy1"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a simple scaling policy de nome {as_scaling_policy_name} no auto scaling group {asg_name}")
    scaling_policies = autoscaling_client.describe_policies(
        AutoScalingGroupName=asg_name,
        PolicyNames=[as_scaling_policy_name],
        PolicyTypes=['SimpleScaling']
    )['ScalingPolicies']

    if scaling_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a simple scaling policy de nome {as_scaling_policy_name} no auto scaling group {asg_name}")
        print(scaling_policies[0]['PolicyName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as simple scaling policies do auto scaling group {asg_name}")
        scaling_policies = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyTypes=['SimpleScaling']
        )['ScalingPolicies']
        for policy in scaling_policies:
            print(policy['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a simple scaling policy de nome {as_scaling_policy_name} no auto scaling group {asg_name}")
        autoscaling_client.put_scaling_policy(
            AutoScalingGroupName=asg_name,
            PolicyName=as_scaling_policy_name,
            PolicyType='SimpleScaling',
            AdjustmentType='ChangeInCapacity',
            ScalingAdjustment=1,
            Cooldown=300
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a simple scaling policy de nome {as_scaling_policy_name} no auto scaling group {asg_name}")
        scaling_policies = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyNames=[as_scaling_policy_name],
            PolicyTypes=['SimpleScaling']
        )['ScalingPolicies']
        print(scaling_policies[0]['PolicyName'])
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("SIMPLE SCALING POLICY EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
as_scaling_policy_name = "asScalingPolicy1"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a simple scaling policy de nome {as_scaling_policy_name} no auto scaling group {asg_name}")
    scaling_policies = autoscaling_client.describe_policies(
        AutoScalingGroupName=asg_name,
        PolicyNames=[as_scaling_policy_name]
    )['ScalingPolicies']

    if scaling_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os auto scaling groups existentes")
        scaling_policies = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name
        )['ScalingPolicies']
        for policy in scaling_policies:
            print(policy['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a simple scaling policy de nome {as_scaling_policy_name} no auto scaling group {asg_name}")
        autoscaling_client.delete_policy(
            AutoScalingGroupName=asg_name,
            PolicyName=as_scaling_policy_name
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os auto scaling groups existentes")
        scaling_policies = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name
        )['ScalingPolicies']
        for policy in scaling_policies:
            print(policy['PolicyName'])
    else:
        print(f"Não existe a simple scaling policy de nome {as_scaling_policy_name} no auto scaling group {asg_name}")
else:
    print("Código não executado")