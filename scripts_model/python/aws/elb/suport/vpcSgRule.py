#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-VPC")
print("SECURITY GROUP RULE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# sg_name = "sgTest1"
sg_name = "default"
# vpc_name = "vpcTest1"
vpc_name = "default"
port = "5000"
protocol = "tcp"
cidr_ipv4 = "0.0.0.0/0"

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
            print(f"Verificando se existe uma regra de entrada liberando a porta {port} do security group {sg_name} da VPC {vpc_name}")     
            exist_rule = []
            for sg_group in sg_groups:
                for rule in sg_group.get('IpPermissions', []):
                    if (
                        rule.get('IpProtocol') == protocol and
                        rule.get('FromPort') == int(port) and
                        rule.get('ToPort') == int(port) and
                        any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))
                    ):
                        exist_rule.append(sg_group['GroupId'])

            if len(exist_rule) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe a regra de entrada liberando a porta {port} do security group {sg_name} da VPC {vpc_name}")
                print(exist_rule)
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o Id de todas as regras de entrada do security group {sg_name} da VPC {vpc_name}")
                all_rules = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_id]}]
                )['SecurityGroupRules']
                ingress_rules = [rule['SecurityGroupRuleId'] for rule in all_rules if not rule['IsEgress']]
                print(ingress_rules)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Adicionando uma regra de entrada ao security group {sg_name} da VPC {vpc_name} para liberação da porta {port}")
                ec2_client.authorize_security_group_ingress(
                    GroupId=sg_id,
                    IpPermissions=[{'IpProtocol': protocol, 'FromPort': int(port), 'ToPort': int(port), 'IpRanges': [{'CidrIp': cidr_ipv4}]}]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o Id da regra de entrada do security group {sg_name} da VPC {vpc_name} que libera a porta {port}")
                sg_groups = ec2_client.describe_security_groups(Filters=[
                    {'Name': 'vpc-id', 'Values': [vpc_id]},
                    {'Name': 'group-name', 'Values': [sg_name]}
                ])['SecurityGroups']
                
                exist_rule = []
                for sg_group in sg_groups:
                    for rule in sg_group.get('IpPermissions', []):
                        if (
                            rule.get('IpProtocol') == protocol and
                            rule.get('FromPort') == int(port) and
                            rule.get('ToPort') == int(port) and
                            any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))
                        ):
                            exist_rule.append(sg_group['GroupId'])
                print(exist_rule)
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
# sg_name = "sgTest1"
sg_name = "default"
# vpc_name = "vpcTest1"
vpc_name = "default"
protocol = "tcp"
port = "5000"
cidr_ipv4 = "0.0.0.0/0"

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
            print(f"Verificando se existe uma regra liberando a porta {port} no security group {sg_name}")
            exist_rule = [rule for rule in sg_groups[0].get('IpPermissions', []) if
                rule.get('IpProtocol') == protocol and
                rule.get('FromPort') == int(port) and
                rule.get('ToPort') == int(port) and
                any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))]

            if len(exist_rule) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o Id de todas as regras de entrada do security group {sg_name}")
                all_rules = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_id]}]
                )['SecurityGroupRules']
                ingress_rules = [rule['SecurityGroupRuleId'] for rule in all_rules if not rule['IsEgress']]
                print(ingress_rules)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo a regra de entrada do security group {sg_name} para liberação da porta {port}")
                ec2_client.revoke_security_group_ingress(
                    GroupId=sg_id,
                    IpPermissions=[{'IpProtocol': protocol, 'FromPort': int(port), 'ToPort': int(port), 'IpRanges': [{'CidrIp': cidr_ipv4}]}]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o Id de todas as regras de entrada do security group {sg_name}")
                all_rules = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_id]}]
                )['SecurityGroupRules']
                ingress_rules = [rule['SecurityGroupRuleId'] for rule in all_rules if not rule['IsEgress']]
                print(ingress_rules)

            else:
                print(f"Não existe a regra de entrada liberando a porta {port} no security group {sg_name}")
        else:
            print(f"Não existe o security group {sg_name}")
    else:
        print(f"Não existe a VPC {vpc_name}")
else:
    print("Código não executado")