#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("AUTO SCALING GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
asg_name = "asgTest1"
launch_temp_name = "launchTempTest1"
version_number = 1
clb_name = "clbTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ").lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2 e outro para o Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')
    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o auto scaling group de nome {asg_name}")
    response = autoscaling_client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name]
    )

    if response['AutoScalingGroups']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o auto scaling group de nome {asg_name}")
        print(response['AutoScalingGroups'][0]['AutoScalingGroupName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os auto scaling groups existentes")
        response = autoscaling_client.describe_auto_scaling_groups()
        for group in response['AutoScalingGroups']:
            print(group['AutoScalingGroupName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o auto scaling group de nome {asg_name}")
        autoscaling_client.create_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            LaunchTemplate={
                'LaunchTemplateName': launch_temp_name,
                'Version': str(version_number)
            },
            MinSize=1,
            MaxSize=4,
            DesiredCapacity=1,
            DefaultCooldown=300,
            HealthCheckType='EC2',
            HealthCheckGracePeriod=300,
            LoadBalancerNames=[clb_name]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Habilitando a coleta de métricas do auto scaling group de nome {asg_name}")
        autoscaling_client.enable_metrics_collection(
            AutoScalingGroupName=asg_name,
            Metrics=[
                'GroupMinSize', 'GroupMaxSize', 'GroupDesiredCapacity',
                'GroupInServiceInstances', 'GroupPendingInstances',
                'GroupStandbyInstances', 'GroupTerminatingInstances',
                'GroupTotalInstances'
            ],
            Granularity='1Minute'
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o auto scaling group de nome {asg_name}")
        response = autoscaling_client.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name]
        )
        print(response['AutoScalingGroups'][0]['AutoScalingGroupName'])
else:
    print("Código não executado")



#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("AUTO SCALING GROUP EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ").lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Auto Scaling")
    autoscaling_client = boto3.client('autoscaling')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o auto scaling group de nome {asg_name}")
    response = autoscaling_client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name]
    )

    if response['AutoScalingGroups']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os grupos de auto scaling existentes")
        response = autoscaling_client.describe_auto_scaling_groups()
        for group in response['AutoScalingGroups']:
            print(group['AutoScalingGroupName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o auto scaling group de nome {asg_name}")
        autoscaling_client.delete_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            ForceDelete=True
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os grupos de auto scaling existentes")
        response = autoscaling_client.describe_auto_scaling_groups()
        for group in response['AutoScalingGroups']:
            print(group['AutoScalingGroupName'])
    else:
        print(f"Não existe o auto scaling group de nome {asg_name}")
else:
    print("Código não executado")