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
        key = "isDefault"
        vpc_name_control = "true"
    else:
        key = "tag:Name"
        vpc_name_control = vpc_name

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a VPC {vpc_name}")
    ec2_client = boto3.client('ec2')
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': key, 'Values': [vpc_name_control]}])['Vpcs']

    if vpcs:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a VPC {vpc_name}")
        print(vpcs[0]['VpcId'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as VPCs existentes")
        all_vpcs = ec2_client.describe_vpcs()['Vpcs']
        for vpc in all_vpcs:
            print(vpc['VpcId'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a VPC {vpc_name}")
        created_vpc = ec2_client.create_vpc(CidrBlock=cidr_block, TagSpecifications=[{'ResourceType': 'vpc', 'Tags': [{'Key': 'Name', 'Value': vpc_name}]}])
        vpc_id = created_vpc['Vpc']['VpcId']
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a VPC {vpc_name}")
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
vpc_name = "vpcTest1"
cidr_block = "10.0.0.0/24"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print("Verificando se a VPC é a padrão ou não")
    if vpc_name == "default":
        key = "isDefault"
        vpc_name_control = "true"
    else:
        key = "tag:Name"
        vpc_name_control = vpc_name

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a VPC {vpc_name}")
    ec2_client = boto3.client('ec2')
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': key, 'Values': [vpc_name_control]}])['Vpcs']

    if len(vpcs) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as VPCs existentes")
        all_vpcs = ec2_client.describe_vpcs()['Vpcs']
        for vpc in all_vpcs:
            print(vpc['VpcId'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da VPC {vpc_name}")
        vpc_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a VPC {vpc_name}")
        try:
            response = ec2_client.delete_vpc(VpcId=vpc_id)
        except ec2_client.exceptions.ClientError as e:
            print("É necessário excluir os elementos de rede desta VPC antes. Verifique as subnets, IGWs, NATGWs, route tables, SGs, etc.")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as VPCs existentes")
        all_vpcs = ec2_client.describe_vpcs()['Vpcs']
        for vpc in all_vpcs:
            print(vpc['VpcId'])
    else:
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")