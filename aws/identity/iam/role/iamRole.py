#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_role_name = "iamRoleTest"
# path_trust_policy_document = "G:\Meu Drive\4_PROJ\scripts\aws\.default\policy\iam\iamTrustPolicy.json"

# SERVICE:
principal = "Service"
principal_name = "ec2.amazonaws.com"

# USER:
# principal = "AWS"
# account_id = "001727357081"
# iam_user_name = "iamUserTest"
# principal_name = f"arn:aws:iam::{account_id}:user/{iam_user_name}"

# ROLE:
# principal = "AWS"
# account_id = "001727357081"
# iam_role_name2 = "iamRoleTest2"
# principal_name = f"arn:aws:iam::{account_id}:role/{iam_role_name2}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role {iam_role_name}")
    iam_client = boto3.client('iam')
    roles = iam_client.list_roles(PathPrefix='/')['Roles']
    iam_role_names = [r['RoleName'] for r in roles]

    if iam_role_name in iam_role_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe uma role {iam_role_name}")
        print(iam_role_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        print("\n".join(iam_role_names))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a role {iam_role_name}")
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {principal: principal_name},
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        iam_client.create_role(RoleName=iam_role_name, AssumeRolePolicyDocument=str(json.dumps(trust_policy)))
        
        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando a role {iam_role_name} com um arquivo JSON")
        # with open(path_trust_policy_document, 'r') as file:
        #     trust_policy_json = file.read()
        # iam_client.create_role(RoleName=iam_role_name, AssumeRolePolicyDocument=trust_policy_json)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a role {iam_role_name}")
        print(iam_role_name)
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_role_name = "iamRoleTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role {iam_role_name}")
    iam_client = boto3.client('iam')
    roles = iam_client.list_roles(PathPrefix='/')['Roles']
    iam_role_names = [r['RoleName'] for r in roles]
    
    if iam_role_name in iam_role_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        print("\n".join(iam_role_names))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existem policies na role {iam_role_name}")
        response = iam_client.list_attached_role_policies(RoleName=iam_role_name)
        attached_policies = response['AttachedPolicies']
        if len(attached_policies) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Separando as policies da role {iam_role_name} em uma lista")
            policy_names = [policy['PolicyName'] for policy in attached_policies]

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo as policies da role {iam_role_name}")
            for policy_name in policy_names:
                policy_response = iam_client.list_policies(Scope='All', MaxItems=1000) # O MaxItems tem o limite de 1000 policies. Contudo existem 1240 polcies, se policy procurada não estiver entre as 1000 encontradas, o valor será None e a política não será removida, impedido a remoção do grupo.
                policy_arn = next((policy['Arn'] for policy in policy_response['Policies'] if policy['PolicyName'] == policy_name), None)
                if policy_arn:
                    iam_client.detach_role_policy(RoleName=iam_role_name, PolicyArn=policy_arn)
        else:
            print(f"Não existem policies na role {iam_role_name}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a role {iam_role_name}")
        iam_client.delete_role(RoleName=iam_role_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        roles_after_deletion = iam_client.list_roles(PathPrefix='/')['Roles']
        iam_role_names_after_deletion = [r['RoleName'] for r in roles_after_deletion]
        print("\n".join(iam_role_names_after_deletion))
    else:
        print(f"Não existe a role {iam_role_name}")
else:
    print("Código não executado")