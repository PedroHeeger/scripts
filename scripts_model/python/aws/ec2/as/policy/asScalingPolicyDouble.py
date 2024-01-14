#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("SIMPLE SCALING POLICY DOUBLE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
as_scaling_policy_name1 = "asScalingPolicy1"
as_scaling_policy_name2 = "asScalingPolicy2"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe uma das simple scaling policies de nomes {as_scaling_policy_name1} e {as_scaling_policy_name2} no auto scaling group {asg_name}")
    
    scaling_policies = autoscaling_client.describe_policies(
        AutoScalingGroupName=asg_name,
        PolicyNames=[as_scaling_policy_name1, as_scaling_policy_name2]
    )['ScalingPolicies']

    if scaling_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe uma das simple scaling policies de nomes {as_scaling_policy_name1} e {as_scaling_policy_name2} no auto scaling group {asg_name}")
        for policy in scaling_policies:
            print(policy['PolicyName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as simple scaling policies do auto scaling group {asg_name}")
        scaling_policies = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyTypes=['SimpleScaling']
        )['ScalingPolicies']
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a simple scaling policy de nome {as_scaling_policy_name1} no auto scaling group {asg_name}")
        autoscaling_client.put_scaling_policy(
            PolicyName=as_scaling_policy_name1,
            AutoScalingGroupName=asg_name,
            PolicyType='SimpleScaling',
            ScalingAdjustment=1,
            AdjustmentType='ChangeInCapacity',
            Cooldown=300
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a simple scaling policy de nome {as_scaling_policy_name2} no auto scaling group {asg_name}")
        autoscaling_client.put_scaling_policy(
            PolicyName=as_scaling_policy_name2,
            AutoScalingGroupName=asg_name,
            PolicyType='SimpleScaling',
            ScalingAdjustment=-1,
            AdjustmentType='ChangeInCapacity',
            Cooldown=300
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando uma das simple scaling policies de nomes {as_scaling_policy_name1} e {as_scaling_policy_name2} no auto scaling group {asg_name}")
        scaling_policies = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyNames=[as_scaling_policy_name1, as_scaling_policy_name2]
        )['ScalingPolicies']
        for policy in scaling_policies:
            print(policy['PolicyName'])
else:
    print("Código não executado")


#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("SIMPLE SCALING POLICY DOUBLE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
as_scaling_policy_name1 = "asScalingPolicy1"
as_scaling_policy_name2 = "asScalingPolicy2"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe uma das simple scaling policies de nomes {as_scaling_policy_name1} e {as_scaling_policy_name2} no auto scaling group {asg_name}")
    scaling_policies = autoscaling_client.describe_policies(
        AutoScalingGroupName=asg_name,
        PolicyNames=[as_scaling_policy_name1, as_scaling_policy_name2]
    )['ScalingPolicies']

    if scaling_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as simple scaling policies do auto scaling group {asg_name}")
        scaling_policy_names = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyTypes=['SimpleScaling']
        )['ScalingPolicies']
        for policy in scaling_policy_names:
            print(policy['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo as simple scaling policies de nomes {as_scaling_policy_name1} e {as_scaling_policy_name2} no auto scaling group {asg_name}")
        autoscaling_client.delete_policy(
            AutoScalingGroupName=asg_name,
            PolicyName=as_scaling_policy_name1
        )
        autoscaling_client.delete_policy(
            AutoScalingGroupName=asg_name,
            PolicyName=as_scaling_policy_name2
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as simple scaling policies do auto scaling group {asg_name}")
        scaling_policy_names = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyTypes=['SimpleScaling']
        )['ScalingPolicies']
        for policy in scaling_policy_names:
            print(policy['PolicyName'])
    else:
        print(f"Não existe uma das simple scaling policies de nomes {as_scaling_policy_name1} e {as_scaling_policy_name2} no auto scaling group {asg_name}")
else:
    print("Código não executado")