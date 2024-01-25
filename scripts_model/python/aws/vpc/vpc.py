#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("VPC CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
vpc_name = "vpcTest1"
# vpc_name = "default"
cidr_block = "10.0.0.0/24"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print("Verificando se a VPC é a padrão ou não")
    if vpc_name == "default":
        condition = "isDefault"
        vpc_name_control = "true"
    else:
        condition = "tag:Name"
        vpc_name_control = vpc_name

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a VPC de nome {vpc_name}")
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': condition, 'Values': [vpc_name_control]}])['Vpcs']

    if vpcs:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a VPC de nome {vpc_name}")
        print(vpcs[0]['VpcId'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as VPCs existentes")
        all_vpcs = ec2_client.describe_vpcs()['Vpcs']
        print([vpc['VpcId'] for vpc in all_vpcs])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a VPC de nome {vpc_name}")
        created_vpc = ec2_client.create_vpc(CidrBlock=cidr_block, TagSpecifications=[{'ResourceType': 'vpc', 'Tags': [{'Key': 'Name', 'Value': vpc_name}]}])
        vpc_id = created_vpc['Vpc']['VpcId']
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a VPC de nome {vpc_name}")
        print(vpc_id)
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("VPC EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
vpc_name = "vpcTest2"
cidr_block = "10.0.0.0/24"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print("Verificando se a VPC é a padrão ou não")
    if vpc_name == "default":
        condition = "isDefault"
        vpc_name_control = "true"
    else:
        condition = "tag:Name"
        vpc_name_control = vpc_name

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a VPC de nome {vpc_name}")
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': condition, 'Values': [vpc_name_control]}])['Vpcs']

    if len(vpcs) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as VPCs existentes")
        all_vpcs = ec2_client.describe_vpcs()['Vpcs']
        print([vpc['VpcId'] for vpc in all_vpcs])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da VPC de nome {vpc_name}")
        vpc_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a VPC de nome {vpc_name}")
        ec2_client.delete_vpc(VpcId=vpc_id)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as VPCs existentes")
        all_vpcs = ec2_client.describe_vpcs()['Vpcs']
        print([vpc['VpcId'] for vpc in all_vpcs])
    else:
        print(f"Não existe a VPC de nome {vpc_name}")
else:
    print("Código não executado")