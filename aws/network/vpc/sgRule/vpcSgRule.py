#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("SECURITY GROUP RULE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
sg_name = "default"
# vpc_name = "default"
# sg_name = "sgTest1"
vpc_name = "vpcTest1"
sg_rule_description = "sgRuleDescriptionTest1"
from_port = "21"
to_port = "21"
protocol = "tcp"
cidr_ipv4 = "0.0.0.0/0"

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
        print(f"Extraindo o Id da VPC {vpc_name}")
        vpc_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o security group {sg_name} na VPC {vpc_name}")
        sg_groups = ec2_client.describe_security_groups(Filters=[
            {'Name': 'vpc-id', 'Values': [vpc_id]},
            {'Name': 'group-name', 'Values': [sg_name]}
        ])['SecurityGroups']

        if len(sg_groups) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id do security group {sg_name} da VPC {vpc_name}")
            sg_id = sg_groups[0]['GroupId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe uma regra de entrada liberando a porta {from_port} no protocolo {protocol} do security group {sg_name} da VPC {vpc_name}")   
            exist_rule = []
            for sg_group in sg_groups:
                for rule in sg_group.get('IpPermissions', []):
                    if (
                        rule.get('IpProtocol') == protocol and
                        rule.get('FromPort') == int(from_port) and
                        rule.get('ToPort') == int(to_port) and
                        any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))
                    ):
                        exist_rule.append(sg_group['GroupId'])

            if len(exist_rule) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe a regra de entrada liberando a porta {from_port} do security group {sg_name} da VPC {vpc_name}")
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
                print(f"Adicionando uma regra de entrada ao security group {sg_name} da VPC {vpc_name} para liberação da porta {from_port}")
                ec2_client.authorize_security_group_ingress(
                    GroupId=sg_id,
                    IpPermissions=[{'IpProtocol': protocol, 'FromPort': int(from_port), 'ToPort': int(to_port), 'IpRanges': [{'CidrIp': cidr_ipv4}]}]
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
                            any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))
                        ):
                            exist_rule.append(sg_group['GroupId'])
                for sg_rule in exist_rule:
                    print(sg_rule)
        else:
            print(f"Não existe o security group {sg_name} na VPC {vpc_name}")
    else:
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("SECURITY GROUP RULE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
sg_name = "default"
# vpc_name = "default"
# sg_name = "sgTest1"
vpc_name = "vpcTest1"
protocol = "tcp"
from_port = "21"
to_port = "21"
cidr_ipv4 = "0.0.0.0/0"

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
    print(f"Criando um cliente para o serviço EC2")
    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a VPC {vpc_name}")
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': key, 'Values': [vpc_name_control]}])['Vpcs']

    if len(vpcs) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da VPC {vpc_name}")
        vpc_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o security group {sg_name} na VPC {vpc_name}")
        sg_groups = ec2_client.describe_security_groups(Filters=[
            {'Name': 'vpc-id', 'Values': [vpc_id]},
            {'Name': 'group-name', 'Values': [sg_name]}
        ])['SecurityGroups']

        if len(sg_groups) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id do security group {sg_name}")
            sg_id = sg_groups[0]['GroupId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe uma regra de entrada liberando a porta {from_port} no protocolo {protocol} do security group {sg_name} da VPC {vpc_name}")
            exist_rule = [rule for rule in sg_groups[0].get('IpPermissions', []) if
                rule.get('IpProtocol') == protocol and
                rule.get('FromPort') == int(from_port) and
                rule.get('ToPort') == int(to_port) and
                any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))]

            if len(exist_rule) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o Id de todas as regras de entrada do security group {sg_name}")
                all_rules = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_id]}]
                )['SecurityGroupRules']
                ingress_rules = [rule['SecurityGroupRuleId'] for rule in all_rules if not rule['IsEgress']]
                for sg_rule in ingress_rules:
                    print(sg_rule)
                # print(ingress_rules)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo a regra de entrada do security group {sg_name} para liberação da porta {from_port}")
                ec2_client.revoke_security_group_ingress(
                    GroupId=sg_id,
                    IpPermissions=[{'IpProtocol': protocol, 'FromPort': int(from_port), 'ToPort': int(to_port), 'IpRanges': [{'CidrIp': cidr_ipv4}]}]
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
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")