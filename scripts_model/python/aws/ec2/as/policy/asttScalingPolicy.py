#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("TARGET TRACKING SCALING POLICY CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
astt_scaling_policy_name = "asttScalingPolicy1"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')
    
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
        response = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyNames=[astt_scaling_policy_name],
            PolicyTypes=['TargetTrackingScaling']
        )

        if response['ScalingPolicies']:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
            print(response['ScalingPolicies'][0]['PolicyName'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as target tracking scaling policies do auto scaling group {asg_name}")
            response = autoscaling_client.describe_policies(
                AutoScalingGroupName=asg_name,
                PolicyTypes=['TargetTrackingScaling']
            )

            for policy in response['ScalingPolicies']:
                print(policy['PolicyName'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
            response = autoscaling_client.put_scaling_policy(
                AutoScalingGroupName=asg_name,
                PolicyName=astt_scaling_policy_name,
                PolicyType='TargetTrackingScaling',
                Cooldown=300,
                TargetTrackingConfiguration={
                    'PredefinedMetricSpecification': {
                        'PredefinedMetricType': 'ASGAverageCPUUtilization'
                    },
                    'TargetValue': 70.0,
                    'DisableScaleIn': False
                }
            )

            # print("-----//-----//-----//-----//-----//-----//-----")
            # print(f"Criando a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
            # response = autoscaling_client.put_scaling_policy(
            #     AutoScalingGroupName=asg_name,
            #     PolicyName=astt_scaling_policy_name,
            #     PolicyType='TargetTrackingScaling',
            #     Cooldown=300,
            #     TargetTrackingConfiguration={
            #         'PredefinedMetricSpecification': {
            #             'PredefinedMetricType': 'ASGAverageCPUUtilization'
            #         },
            #         'TargetValue': 30.0,
            #         'DisableScaleIn': False
            #     }
            # )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
            response = autoscaling_client.describe_policies(
                AutoScalingGroupName=asg_name,
                PolicyNames=[astt_scaling_policy_name],
                PolicyTypes=['TargetTrackingScaling']
            )

            print(response['ScalingPolicies'][0]['PolicyName'])
    except Exception as e:
        print(f"Erro: {e}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("TARGET TRACKING SCALING POLICY EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
astt_scaling_policy_name = "asttScalingPolicy1"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
        response = autoscaling_client.describe_policies(
            AutoScalingGroupName=asg_name,
            PolicyNames=[astt_scaling_policy_name],
            PolicyTypes=['TargetTrackingScaling']
        )

        if response['ScalingPolicies']:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as target tracking scaling policies do auto scaling group {asg_name}")
            response = autoscaling_client.describe_policies(
                AutoScalingGroupName=asg_name,
                PolicyTypes=['TargetTrackingScaling']
            )

            for policy in response['ScalingPolicies']:
                print(policy['PolicyName'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
            autoscaling_client.delete_policy(
                AutoScalingGroupName=asg_name,
                PolicyName=astt_scaling_policy_name
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as target tracking scaling policies do auto scaling group {asg_name}")
            response = autoscaling_client.describe_policies(
                AutoScalingGroupName=asg_name,
                PolicyTypes=['TargetTrackingScaling']
            )

            for policy in response['ScalingPolicies']:
                print(policy['PolicyName'])

        else:
            print(f"Não existe a target tracking scaling policy de nome {astt_scaling_policy_name} no auto scaling group {asg_name}")
    except Exception as e:
        print(f"Erro: {e}")
else:
    print("Código não executado")