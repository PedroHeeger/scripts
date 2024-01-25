#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("APPLICATION LOAD BALANCER (ALB) CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"
aZ1 = "us-east-1a"
aZ2 = "us-east-1b"
sg_name = "default"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o load balancer de nome {alb_name}")
    try:
        response = elbv2_client.describe_load_balancers(Names=[alb_name])
        existing_alb_name = response['LoadBalancers'][0]['LoadBalancerName']
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o load balancer de nome {alb_name}")
        print(existing_alb_name)

    except ClientError as e:
        if e.response['Error']['Code'] == 'LoadBalancerNotFound':
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todos os load balancers criados")
            response = elbv2_client.describe_load_balancers()
            print([lb['LoadBalancerName'] for lb in response['LoadBalancers']])

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo o Id dos elementos de rede")
            vpc_id = boto3.client('ec2').describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])['Vpcs'][0]['VpcId']
            subnet_id1 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ1]}, {'Name': 'vpc-id', 'Values': [vpc_id]}])['Subnets'][0]['SubnetId']
            subnet_id2 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ2]}, {'Name': 'vpc-id', 'Values': [vpc_id]}])['Subnets'][0]['SubnetId']
            sg_id = boto3.client('ec2').describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}, {'Name': 'group-name', 'Values': [sg_name]}])['SecurityGroups'][0]['GroupId']
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o load balancer de nome {alb_name}")
            elbv2_client.create_load_balancer(
                Name=alb_name,
                Type='application',
                Scheme='internet-facing',
                IpAddressType='ipv4',
                Subnets=[subnet_id1, subnet_id2],
                SecurityGroups=[sg_id]
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o load balancer de nome {alb_name}")
            response = elbv2_client.describe_load_balancers(Names=[alb_name])
            print(response['LoadBalancers'][0]['LoadBalancerName'])
        else:
            raise  # Re-raise outras exceções
else:
    print("Código não executado")



#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("APPLICATION LOAD BALANCER (ALB) EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o load balancer de nome {alb_name}")
    response = elbv2_client.describe_load_balancers(
        Names=[alb_name]
    )

    if len(response['LoadBalancers']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os load balancers criados")
        response = elbv2_client.describe_load_balancers()
        print([lb['LoadBalancerName'] for lb in response['LoadBalancers']])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do load balancer de nome {alb_name}")
        lb_arn = response['LoadBalancers'][0]['LoadBalancerArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o load balancer de nome {alb_name}")
        elbv2_client.delete_load_balancer(LoadBalancerArn=lb_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os load balancers criados")
        response = elbv2_client.describe_load_balancers()
        print([lb['LoadBalancerName'] for lb in response['LoadBalancers']])
    else:
        print(f"Não existe o load balancer de nome {alb_name}")
else:
    print("Código não executado")