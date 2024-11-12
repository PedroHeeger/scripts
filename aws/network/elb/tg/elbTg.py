#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ELB")
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
healthy_threshold = 5
unhealthy_threshold = 2
hc_timeout_seconds = 5
hc_interval_seconds = 15
hc_matcher = "200-299"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o target group {tg_name}")
    elbv2_client = boto3.client('elbv2')

    try:
        response = elbv2_client.describe_target_groups(Names=[tg_name])
        target_group_found = len(response['TargetGroups']) > 0
    except ClientError as e:
        target_group_found = False

    if target_group_found:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o target group {tg_name}")
        print(response['TargetGroups'][0]['TargetGroupName'])
    else:
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
        print(f"Criando o target group {tg_name}")
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
            HealthyThresholdCount=healthy_threshold,
            UnhealthyThresholdCount=unhealthy_threshold,
            HealthCheckTimeoutSeconds=hc_timeout_seconds,
            HealthCheckIntervalSeconds=hc_interval_seconds,
            Matcher={'HttpCode': hc_matcher}
        )
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o target group {tg_name}")
        print(response['TargetGroups'][0]['TargetGroupName'])
else:
    print("Código não executado")



#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ELB")
print("TARGET GROUP EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tg_name = "tgTest1"
alb_name = "albTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o target group {tg_name}")
    elbv2_client = boto3.client('elbv2')
    
    try:
        response = elbv2_client.describe_target_groups(Names=[tg_name])
        target_group_found = len(response['TargetGroups']) > 0
    except ClientError as e:
        target_group_found = False

    if target_group_found:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os target groups criados")
        response = elbv2_client.describe_target_groups()
        for tg in response['TargetGroups']:
            print(tg['TargetGroupName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o load balancer {alb_name}")
        try:
            response = elbv2_client.describe_load_balancers(Names=[alb_name])
            lb_found = len(response['LoadBalancers']) > 0
        except ClientError as e:
            lb_found = False

        if lb_found:         
            print(f"Necessário excluir o load balancer {alb_name} antes de excluir o target group {tg_name}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo a ARN do target group {tg_name}")
            response = elbv2_client.describe_target_groups(Names=[tg_name])
            tg_arn = response['TargetGroups'][0]['TargetGroupArn']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o target group {tg_name}")
            elbv2_client.delete_target_group(TargetGroupArn=tg_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os target groups criados")
        response = elbv2_client.describe_target_groups()
        for tg in response['TargetGroups']:
            print(tg['TargetGroupName'])
    else:
        print(f"Não existe o target group {tg_name}")
else:
    print("Código não executado")