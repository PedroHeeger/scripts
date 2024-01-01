#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS VPC")
print("SECURITY GROUP RULE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
group_name = "default"
protocol = "tcp"
port = "5000"
cidr_ipv4 = "0.0.0.0/0"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Verificando se existe a VPC padrão")
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])['Vpcs']

    if len(vpcs) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id da VPC padrão")
        vpc_default_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Verificando se existe o Security Group padrão da VPC padrão")
        sgs = ec2_client.describe_security_groups(
            Filters=[{'Name': 'vpc-id', 'Values': [vpc_default_id]}, {'Name': 'group-name', 'Values': [group_name]}]
        )['SecurityGroups']

        if len(sgs) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo o Id do Security Group padrão")
            sg_default_id = sgs[0]['GroupId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe uma regra liberando a porta {port} do Security Group padrão")
            # exist_rule = ec2_client.describe_security_group_rules(
            #     Filters=[
            #         {'Name': 'group-id', 'Values': [sg_default_id]},
            #         # {'Name': 'ip-permission.protocol', 'Values': ["-1"]},
            #         {'Name': 'ip-permission.from-port', 'Values': [str(22)]},
            #         {'Name': 'ip-permission.to-port', 'Values': [str(port)]},
            #         {'Name': 'ip-permission.cidr', 'Values': [cidr_ipv4]}
            #     ]
            # )['SecurityGroupRules']

            exist_rule = [rule for rule in sgs[0].get('IpPermissions', []) if
                
                rule.get('GroupId') == sg_default_id and
                rule.get('IpProtocol') == protocol and
                rule.get('FromPort') == port and
                rule.get('ToPort') == port and
                any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))]

            if exist_rule:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe a regra de entrada liberando a porta {port} do Security Group padrão")
                print(exist_rule)
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print("Listando o Id de todas as regras de entrada e saída do Security Group padrão")
                rules = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_default_id]}]
                )['SecurityGroupRules']

                for rule in rules:
                    print(rule['SecurityGroupRuleId'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Adicionando uma regra de entrada ao Security Group padrão para liberação da porta {port}")
                ec2_client.authorize_security_group_ingress(
                    GroupId=sg_default_id,
                    IpPermissions=[
                        {'IpProtocol': protocol, 'FromPort': int(port), 'ToPort': int(port), 'IpRanges': [{'CidrIp': cidr_ipv4}]}
                    ]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print("Listando o Id de todas as regras de entrada e saída do Security Group padrão")
                rules_after = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_default_id]}]
                )['SecurityGroupRules']

                for rule in rules_after:
                    print(rule['SecurityGroupRuleId'])
    else:
        print("VPC padrão não encontrada")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS VPC")
print("SECURITY GROUP RULE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
group_name = "default"
protocol = "tcp"
port = 5000
cidr_ipv4 = "0.0.0.0/0"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':


    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Verificando se existe a VPC padrão")
    vpcs = ec2_client.describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])['Vpcs']

    if len(vpcs) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id da VPC padrão")
        vpc_default_id = vpcs[0]['VpcId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Verificando se existe o Security Group padrão da VPC padrão")
        sgs = ec2_client.describe_security_groups(
            Filters=[{'Name': 'vpc-id', 'Values': [vpc_default_id]}, {'Name': 'group-name', 'Values': [group_name]}]
        )['SecurityGroups']

        if len(sgs) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo o Id do Security Group padrão")
            sg_default_id = sgs[0]['GroupId']

            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe uma regra liberando a porta {port} no Security Group padrão")

            exist_rule = [rule for rule in sgs[0].get('IpPermissions', []) if
               rule.get('IpProtocol') == protocol and
               rule.get('FromPort') == port and
               rule.get('ToPort') == port and
               any(ip_range['CidrIp'] == cidr_ipv4 for ip_range in rule.get('IpRanges', []))]

            if exist_rule:
                print("Listando o Id de todas as regras de entrada e saída do Security Group padrão")
                rules = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_default_id]}]
                )['SecurityGroupRules']

                for rule in rules:
                    print(rule['SecurityGroupRuleId'])

                print(f"Removendo a regra de entrada do Security Group padrão para liberação da porta {port}")
                ec2_client.revoke_security_group_ingress(
                    GroupId=sg_default_id,
                    IpPermissions=[
                        {'IpProtocol': protocol, 'FromPort': port, 'ToPort': port, 'IpRanges': [{'CidrIp': cidr_ipv4}]}
                    ]
                )

                print("Listando o Id de todas as regras de entrada e saída do Security Group padrão")
                updated_rules = ec2_client.describe_security_group_rules(
                    Filters=[{'Name': 'group-id', 'Values': [sg_default_id]}]
                )['SecurityGroupRules']

                for rule in updated_rules:
                    print(rule['SecurityGroupRuleId'])
            else:
                print(f"Não existe a regra de entrada liberando a porta {port} no Security Group padrão")
        else:
            print(f"Security Group padrão com o nome {group_name} não encontrado na VPC padrão")
    else:
        print("VPC padrão não encontrada")
else:
    print("Código não executado")