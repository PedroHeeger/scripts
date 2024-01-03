#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("TARGET GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tg_name = "tgTest1"
tg_type = "instance"
# tg_type = "ip"
tg_protocol = "HTTP"
tg_protocol_version = "HTTP1"
tg_port = 80
tg_health_check_protocol = "HTTP"
tg_health_check_port = "traffic-port"
tg_health_check_path = "/"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o target group de nome {tg_name}")
    try:
        response = elbv2_client.describe_target_groups(Names=[tg_name])
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o target group de nome {tg_name}")
        print(response['TargetGroups'][0]['TargetGroupName'])
    except elbv2_client.exceptions.TargetGroupNotFoundException:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os target groups criados")
        response = elbv2_client.describe_target_groups()
        for tg in response['TargetGroups']:
            print(tg['TargetGroupName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id da VPC padrão")
        ec2_client = boto3.client('ec2')
        vpcs = ec2_client.describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])
        vpc_id = vpcs['Vpcs'][0]['VpcId']
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o target group de nome {tg_name}")
        response = elbv2_client.create_target_group(
            Name=tg_name,
            TargetType=tg_type,
            Protocol=tg_protocol,
            ProtocolVersion=tg_protocol_version,
            Port=tg_port,
            VpcId=vpc_id,
            HealthCheckProtocol=tg_health_check_protocol,
            HealthCheckPort=tg_health_check_port,
            HealthCheckPath=tg_health_check_path,
            HealthyThresholdCount=5,
            UnhealthyThresholdCount=2,
            HealthCheckTimeoutSeconds=5,
            HealthCheckIntervalSeconds=15,
            Matcher={'HttpCode': '200-299'}
        )
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o target group de nome {tg_name}")
        print(response['TargetGroups'][0]['TargetGroupName'])
else:
    print("Código não executado")



#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("TARGET GROUP EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tg_name = "tgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o target group de nome {tg_name}")
    response = elbv2_client.describe_target_groups(
        Names=[tg_name]
    )

    if len(response['TargetGroups']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os target groups criados")
        response = elbv2_client.describe_target_groups()
        for tg in response['TargetGroups']:
            print(tg['TargetGroupName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do target group de nome {tg_name}")
        tg_arn = response['TargetGroups'][0]['TargetGroupArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o target group de nome {tg_name}")
        elbv2_client.delete_target_group(TargetGroupArn=tg_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os target groups criados")
        response = elbv2_client.describe_target_groups()
        for tg in response['TargetGroups']:
            print(tg['TargetGroupName'])
    else:
        print(f"Não existe o target group de nome {tg_name}")
else:
    print("Código não executado")