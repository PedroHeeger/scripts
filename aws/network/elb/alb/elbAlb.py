#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ELB")
print("APPLICATION LOAD BALANCER (ALB) CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"
aZ1 = "us-east-1a"
aZ2 = "us-east-1b"
sg_name = "default"
type_ = "application"        # Nome 'type_' usado para evitar conflito com a palavra reservada 'type'
scheme = "internet-facing"
ip_address_type = "ipv4"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':   
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o load balancer {alb_name}")
    elbv2_client = boto3.client('elbv2')

    try:
        response = elbv2_client.describe_load_balancers(Names=[alb_name])
        lb_found = len(response['LoadBalancers']) > 0
    except ClientError as e:
        lb_found = False

    if lb_found:
        existing_alb_name = response['LoadBalancers'][0]['LoadBalancerName']
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o load balancer {alb_name}")
        print(existing_alb_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os load balancers criados")
        response = elbv2_client.describe_load_balancers()
        for lb in response['LoadBalancers']:
            print(lb['LoadBalancerName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
        vpc_id = boto3.client('ec2').describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])['Vpcs'][0]['VpcId']
        subnet_id1 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ1]}, {'Name': 'vpc-id', 'Values': [vpc_id]}])['Subnets'][0]['SubnetId']
        subnet_id2 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ2]}, {'Name': 'vpc-id', 'Values': [vpc_id]}])['Subnets'][0]['SubnetId']
        sg_id = boto3.client('ec2').describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}, {'Name': 'group-name', 'Values': [sg_name]}])['SecurityGroups'][0]['GroupId']
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o load balancer {alb_name}")
        elbv2_client.create_load_balancer(
            Name=alb_name,
            Type=type_,
            Scheme=scheme,
            IpAddressType=ip_address_type,
            Subnets=[subnet_id1, subnet_id2],
            SecurityGroups=[sg_id]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o load balancer {alb_name}")
        response = elbv2_client.describe_load_balancers(Names=[alb_name])
        print(response['LoadBalancers'][0]['LoadBalancerName'])
else:
    print("Código não executado")



#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS ELB")
print("APPLICATION LOAD BALANCER (ALB) EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o load balancer {alb_name}")
    elbv2_client = boto3.client('elbv2')

    try:
        response = elbv2_client.describe_load_balancers(Names=[alb_name])
        lb_found = len(response['LoadBalancers']) > 0
    except ClientError as e:
        lb_found = False

    if lb_found:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os load balancers criados")
        response = elbv2_client.describe_load_balancers()
        for lb in response['LoadBalancers']:
            print(lb['LoadBalancerName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do load balancer {alb_name}")
        lb_arn = response['LoadBalancers'][0]['LoadBalancerArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o load balancer {alb_name}")
        elbv2_client.delete_load_balancer(LoadBalancerArn=lb_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os load balancers criados")
        response = elbv2_client.describe_load_balancers()
        for lb in response['LoadBalancers']:
            print(lb['LoadBalancerName'])
    else:
        print(f"Não existe o load balancer {alb_name}")
else:
    print("Código não executado")