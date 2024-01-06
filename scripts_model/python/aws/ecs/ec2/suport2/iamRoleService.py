#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE SERVICE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
role_name = "ecs-ec2InstanceRole"
service_name = "ec2.amazonaws.com"
# path_trust_policy_document = "G:\Meu Drive\4_PROJ\scripts\scripts_model\.default\aws\iamTrustPolicy.json"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role de nome {role_name}")
    roles = iam_client.list_roles(PathPrefix='/')['Roles']
    role_names = [r['RoleName'] for r in roles]
    if role_name in role_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe uma role de nome {role_name}")
        print(role_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        print("\n".join(role_names))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a role de nome {role_name}")
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"Service": service_name},
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        iam_client.create_role(RoleName=role_name, AssumeRolePolicyDocument=str(json.dumps(trust_policy)))
        
        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando a role de nome {role_name} com um arquivo JSON")
        # with open(path_trust_policy_document, 'r') as file:
        #     trust_policy_json = file.read()
        # iam_client.create_role(RoleName=role_name, AssumeRolePolicyDocument=trust_policy_json)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a role de nome {role_name}")
        print(role_name)
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE SERVICE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
role_name = "ecs-ec2InstanceRole"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role de nome {role_name}")
    iam_client = boto3.client('iam')
    roles = iam_client.list_roles(PathPrefix='/')['Roles']
    role_names = [r['RoleName'] for r in roles]
    
    if role_name in role_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        print("\n".join(role_names))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Obtendo a lista de ARNs de policies anexadas à role de nome {role_name}")
        attached_policies = iam_client.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Iterando na lista de policies")
        for policy in attached_policies:
            policy_arn = policy['PolicyArn']
            policy_name = iam_client.get_policy(PolicyArn=policy_arn)['Policy']['PolicyName']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a policy {policy_name} da role de nome {role_name}")
            iam_client.detach_role_policy(RoleName=role_name, PolicyArn=policy_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a role de nome {role_name}")
        iam_client.delete_role(RoleName=role_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        roles_after_deletion = iam_client.list_roles(PathPrefix='/')['Roles']
        role_names_after_deletion = [r['RoleName'] for r in roles_after_deletion]
        print("\n".join(role_names_after_deletion))
    else:
        print(f"Não existe a role de nome {role_name}")
else:
    print("Código não executado")