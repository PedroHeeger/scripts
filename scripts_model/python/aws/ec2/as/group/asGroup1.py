#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-AUTO SCALING")
print("AUTO SCALING GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
asg_name = "asgTest1"
launch_config_name = "launchConfigTest1"
launch_temp_name = "launchTempTest1"
version_number = 1
tg_name = "tgTest1"
az1 = "us-east-1a"
az2 = "us-east-1b"
tag_name_instance = "ec2Test"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ").lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2, outro para o Auto Scaling e outro para o ELB")
    ec2_client = boto3.client('ec2')
    autoscaling_client = boto3.client('autoscaling')
    elbv2_client = boto3.client('elbv2')

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
        print("Extraindo o ARN do target group")
        response = elbv2_client.describe_target_groups(
        Names=[tg_name]
        )
        tg_arn = response['TargetGroups'][0]['TargetGroupArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo os IDs dos elementos de rede")
        vpc_id = ec2_client.describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])['Vpcs'][0]['VpcId']
        subnet_id1 = ec2_client.describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [az1]}, {'Name': 'vpc-id', 'Values': [vpc_id]}])['Subnets'][0]['SubnetId']
        subnet_id2 = ec2_client.describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [az2]}, {'Name': 'vpc-id', 'Values': [vpc_id]}])['Subnets'][0]['SubnetId']

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando o auto scaling group de nome {asg_name}")
        # autoscaling_client.create_auto_scaling_group(
        #     AutoScalingGroupName=asg_name,
        #     LaunchConfigurationName=launch_config_name,
        #     MinSize=1,
        #     MaxSize=4,
        #     DesiredCapacity=1,
        #     DefaultCooldown=300,
        #     HealthCheckType='EC2',
        #     HealthCheckGracePeriod=300,
        #     VPCZoneIdentifier=f"{subnet_id1},{subnet_id2}",
        #     Tags=[
        #         {
        #             'Key': 'Name',
        #             'Value': tag_name_instance,
        #             'PropagateAtLaunch': True
        #         }
        #     ],
        #     TargetGroupARNs=[tg_arn]
        # )

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
            VPCZoneIdentifier=f"{subnet_id1},{subnet_id2}",
            Tags=[
                {
                    'Key': 'Name',
                    'Value': tag_name_instance,
                    'PropagateAtLaunch': True
                }
            ],
            TargetGroupARNs=[tg_arn]
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