#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("SECURITY GROUP RULE SG CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
sg_name = "default"
# vpc_name = "default"
# sg_name = "sgTest1"
vpc_name = "vpcTest1"
sg_rule_description = "sgRuleDescriptionTest1"
from_port = 22
to_port = 22
protocol = "tcp"
refer_sg_name = "sgReferTest1"

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
    response = ec2_client.describe_vpcs(Filters=[{'Name': key, 'Values': [vpc_name_control]}])
    if len(response['Vpcs']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da VPC {vpc_name}")
        vpc_id = response['Vpcs'][0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o security group de referência {refer_sg_name} na VPC {vpc_name}")
        response = ec2_client.describe_security_groups(Filters=[
            {'Name': 'vpc-id', 'Values': [vpc_id]},
            {'Name': 'group-name', 'Values': [refer_sg_name]}
        ])

        if len(response['SecurityGroups']) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o security group {sg_name} na VPC {vpc_name}")
            response = ec2_client.describe_security_groups(Filters=[
                {'Name': 'vpc-id', 'Values': [vpc_id]},
                {'Name': 'group-name', 'Values': [sg_name]}
            ])

            if len(response['SecurityGroups']) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o Id do security group {sg_name} da VPC {vpc_name}")
                sg_id = response['SecurityGroups'][0]['GroupId']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o Id do security group vinculado {refer_sg_name}")
                responseSg2 = ec2_client.describe_security_groups(Filters=[
                    {'Name': 'group-name', 'Values': [refer_sg_name]}
                ])
                refer_sg_id = responseSg2['SecurityGroups'][0]['GroupId']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe uma regra de entrada liberando a porta {from_port} no {protocol} do security group {sg_name} da VPC {vpc_name}")
                exist_rule = []
                for sg_group in response['SecurityGroups']:
                    for rule in sg_group.get('IpPermissions', []):
                        if (
                            rule.get('IpProtocol') == protocol and
                            rule.get('FromPort') == int(from_port) and
                            rule.get('ToPort') == int(to_port) and
                            any(user_pair['GroupId'] == refer_sg_id for user_pair in rule.get('UserIdGroupPairs', []))
                        ):
                            exist_rule.append(sg_group['GroupId'])

                if len(exist_rule) > 0:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Já existe a regra de entrada liberando a porta {from_port} no protocolo {protocol} do security group {sg_name} da VPC {vpc_name}")
                    for sg_rule in exist_rule:
                        print(sg_rule)
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando o Id de todas as regras de entrada do security group {sg_name} da VPC {vpc_name}")
                    all_rules = ec2_client.describe_security_group_rules(
                        Filters=[{'Name': 'group-id', 'Values': [sg_id]}]
                    )['SecurityGroupRules']
                    ingress_rules = [rule['SecurityGroupRuleId'] for rule in all_rules if not rule['IsEgress']]
                    for sg_rule in ingress_rules:
                        print(sg_rule)

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Criando uma regra de entrada ao security group {sg_name} da VPC {vpc_name} para liberação da porta {from_port}")
                    ec2_client.authorize_security_group_ingress(
                        GroupId=sg_id,
                        IpPermissions=[
                            {
                                'IpProtocol': protocol,
                                'FromPort': from_port,
                                'ToPort': to_port,
                                'UserIdGroupPairs': [
                                    {
                                        'GroupId': refer_sg_id,
                                        'Description': sg_rule_description
                                    }
                                ]
                            }
                        ]
                    )

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando o Id da regra de entrada do security group {sg_name} da VPC {vpc_name} que libera a porta {from_port}")
                    sg_groups = ec2_client.describe_security_groups(Filters=[
                        {'Name': 'vpc-id', 'Values': [vpc_id]},
                        {'Name': 'group-name', 'Values': [sg_name]}
                    ])['SecurityGroups']
                    
                    exist_rule = []
                    for sg_group in sg_groups:
                        for rule in sg_group.get('IpPermissions', []):
                            if (
                                rule.get('IpProtocol') == protocol and
                                rule.get('FromPort') == int(from_port) and
                                rule.get('ToPort') == int(to_port) and
                                any(user_pair['GroupId'] == refer_sg_id for user_pair in rule.get('UserIdGroupPairs', []))
                            ):
                                exist_rule.append(sg_group['GroupId'])
                    for sg_rule in exist_rule:
                        print(sg_rule)
            else:
                print(f"Não existe o security group {sg_name}")
        else:
            print(f"Não existe o security group de referência {refer_sg_name}")
    else:
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("SECURITY GROUP RULE SG EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
sg_name = "default"
# vpc_name = "default"
# sg_name = "sgTest1"
vpc_name = "vpcTest1"
protocol = "tcp"
from_port = 22
to_port = 22
refer_sg_name = "sgReferTest1"

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
    response = ec2_client.describe_vpcs(Filters=[{'Name': key, 'Values': [vpc_name_control]}])
    if len(response['Vpcs']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da VPC {vpc_name}")
        vpc_id = response['Vpcs'][0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o security group de referência {refer_sg_name} na VPC {vpc_name}")
        response = ec2_client.describe_security_groups(Filters=[
            {'Name': 'vpc-id', 'Values': [vpc_id]},
            {'Name': 'group-name', 'Values': [refer_sg_name]}
        ])

        if len(response['SecurityGroups']) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o security group {sg_name} na VPC {vpc_name}")
            response = ec2_client.describe_security_groups(Filters=[
                {'Name': 'vpc-id', 'Values': [vpc_id]},
                {'Name': 'group-name', 'Values': [sg_name]}
            ])
            if len(response['SecurityGroups']) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o Id do security group {sg_name}")
                sg_id = response['SecurityGroups'][0]['GroupId']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o Id do security group vinculado {refer_sg_name}")
                responseSg2 = ec2_client.describe_security_groups(Filters=[
                    {'Name': 'group-name', 'Values': [refer_sg_name]}
                ])
                refer_sg_id = responseSg2['SecurityGroups'][0]['GroupId']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe uma regra de entrada liberando a porta {from_port} no {protocol} do security group {sg_name} da VPC {vpc_name}")
                exist_rule = []
                for sg_group in response['SecurityGroups']:
                    for rule in sg_group.get('IpPermissions', []):
                        if (
                            rule.get('IpProtocol') == protocol and
                            rule.get('FromPort') == int(from_port) and
                            rule.get('ToPort') == int(to_port) and
                            any(user_pair['GroupId'] == refer_sg_id for user_pair in rule.get('UserIdGroupPairs', []))
                        ):
                            exist_rule.append(sg_group['GroupId'])

                if len(exist_rule) > 0:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando o Id de todas as regras de entrada do security group {sg_name}")
                    all_rules = ec2_client.describe_security_group_rules(
                        Filters=[{'Name': 'group-id', 'Values': [sg_id]}]
                    )['SecurityGroupRules']
                    ingress_rules = [rule['SecurityGroupRuleId'] for rule in all_rules if not rule['IsEgress']]
                    for sg_rule in ingress_rules:
                        print(sg_rule)

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Removendo a regra de entrada do security group {sg_name} para liberação da porta {from_port}")
                    ec2_client.revoke_security_group_ingress(
                        GroupId=sg_id,
                        IpPermissions=[
                            {
                                'IpProtocol': protocol,
                                'FromPort': from_port,
                                'ToPort': to_port,
                                'UserIdGroupPairs': [
                                    {
                                        'GroupId':  refer_sg_id
                                    }
                                ]
                            }
                        ]
                    )

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando o Id de todas as regras de entrada do security group {sg_name}")
                    all_rules = ec2_client.describe_security_group_rules(
                        Filters=[{'Name': 'group-id', 'Values': [sg_id]}]
                    )['SecurityGroupRules']
                    ingress_rules = [rule['SecurityGroupRuleId'] for rule in all_rules if not rule['IsEgress']]
                    for sg_rule in ingress_rules:
                        print(sg_rule)
                else:
                    print(f"Não existe a regra de entrada liberando a porta {from_port} no protocolo {protocol} do security group {sg_name} da VPC {vpc_name}")
            else:
                print(f"Não existe o security group {sg_name}")
        else:
            print(f"Não existe o security group de referência {refer_sg_name}")            
    else:
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")