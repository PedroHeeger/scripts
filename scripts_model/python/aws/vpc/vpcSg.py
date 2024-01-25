#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("SECURITY GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
sg_name = "sgTest1"
# sg_name = "default"
vpc_name = "vpcTest1"
# vpc_name = "default"
sg_description = "Security Group Test1"
sg_tag_name = "sgTest1"

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
    print(f"Verificando se existe a VPC {vpc_name}")
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': condition, 'Values': [vpc_name_control]}])['Vpcs']

    if len(vpcs) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da VPC {vpc_name}")
        vpc_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o security group de nome {sg_name} na VPC {vpc_name}")
        sg_groups = ec2_client.describe_security_groups(Filters=[
            {'Name': 'vpc-id', 'Values': [vpc_id]},
            {'Name': 'group-name', 'Values': [sg_name]}
        ])['SecurityGroups']

        if len(sg_groups) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o security group de nome {sg_name} na VPC {vpc_name}")
            print(sg_groups[0]['GroupName'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os security groups criados na VPC {vpc_name}")
            all_sgs = ec2_client.describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])['SecurityGroups']
            print([sg['GroupName'] for sg in all_sgs])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o security group de nome {sg_name} na VPC {vpc_name}")
            created_sg = ec2_client.create_security_group(GroupName=sg_name, Description=sg_description, VpcId=vpc_id)
            sg_id = created_sg['GroupId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o security group de nome {sg_name} na VPC {vpc_name}")
            sg_info = ec2_client.describe_security_groups(GroupIds=[sg_id])['SecurityGroups']
            print(sg_info[0]['GroupName'])
    else:
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("SECURITY GROUP EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
sg_name = "sgTest1"
# sg_name = "default"
vpc_name = "vpcTest1"
# vpc_name = "default"

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
    print(f"Verificando se existe a VPC {vpc_name}")
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': condition, 'Values': [vpc_name_control]}])['Vpcs']

    if len(vpcs) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da VPC {vpc_name}")
        vpc_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o security group de nome {sg_name} na VPC {vpc_name}")
        sg_groups = ec2_client.describe_security_groups(Filters=[
            {'Name': 'vpc-id', 'Values': [vpc_id]},
            {'Name': 'group-name', 'Values': [sg_name]}
        ])['SecurityGroups']

        if len(sg_groups) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os security groups criados na VPC {vpc_name}")
            all_sgs = ec2_client.describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])['SecurityGroups']
            print([sg['GroupName'] for sg in all_sgs])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id do security group de nome {sg_name} da VPC {vpc_name}")
            sg_id = sg_groups[0]['GroupId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o security group de nome {sg_name} da VPC {vpc_name}")
            ec2_client.delete_security_group(GroupId=sg_id)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os security groups criados na VPC {vpc_name}")
            all_sgs = ec2_client.describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])['SecurityGroups']
            print([sg['GroupName'] for sg in all_sgs])
        else:
            print(f"Não existe o security group de nome {sg_name} na VPC {vpc_name}")
    else:
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")