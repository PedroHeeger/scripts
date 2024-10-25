#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM POLICY CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
policy_name = "policyTest"
account_id = "001727357081"
policy_arn = f"arn:aws:iam::{account_id}:policy/{policy_name}"
path_policy_document = "G:\\Meu Drive\\4_PROJ\\scripts\\scripts_model\\.default\\aws\\iamPolicy.json"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y': 
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a policy {policy_name}")
    iam = boto3.client('iam')
    response = iam.list_policies(Scope='Local', MaxItems=1000)
    policies = response['Policies']
    
    existing_policies = [p for p in policies if p['PolicyName'] == policy_name]
    if existing_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a policy {policy_name}")
        print(existing_policies[0]['PolicyName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as polices criadas pelo usuário")
        for p in policies:
            if p['Arn'].startswith(f'arn:aws:iam::{account_id}:'):
                print(p['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a polciy {policy_name}")
        policy_document = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": "s3:GetObject",
                    "Resource": "arn:aws:s3:::seu-bucket/*"
                }
            ]
        }

        iam.create_policy(
            PolicyName=policy_name,
            PolicyDocument=json.dumps(policy_document)
        )

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando a polciy {policy_name} a partir do arquivo JSON")
        # # Carregando o conteúdo do arquivo JSON
        # with open(path_policy_document, 'r') as file:
        #     policy_document_content = json.load(file)

        # iam.create_policy(
        #     PolicyName=policy_name,
        #     PolicyDocument=json.dumps(policy_document_content)
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a policy {policy_name}")
        response = iam.list_policies(Scope='Local', MaxItems=1000)
        policies = response['Policies']
        existing_policies = [p for p in policies if p['PolicyName'] == policy_name]
        print(existing_policies[0]['PolicyName'] if existing_policies else f"A policy {policy_name} não foi encontrada.")
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM POLICY EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
policy_name = "policyTest"
account_id = "001727357081"
policy_arn = f"arn:aws:iam::{account_id}:policy/{policy_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a policy {policy_name}")
    iam = boto3.client('iam')
    existing_policies = iam.list_policies(Scope='Local', MaxItems=1000)['Policies']
    matching_policies = [p for p in existing_policies if p['PolicyName'] == policy_name]

    if matching_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as polices criadas pelo usuário")
        policies = iam.list_policies(Scope='Local', MaxItems=1000)['Policies']
        for p in policies:
            if p['Arn'].startswith(f'arn:aws:iam::{account_id}:'):
                print(p['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da policy {policy_name}")
        policy_arn = matching_policies[0]['Arn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a policy {policy_name}")
        iam.delete_policy(PolicyArn=policy_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as polices criadas pelo usuário")
        policies = iam.list_policies(Scope='Local', MaxItems=1000)['Policies']
        for p in policies:
            if p['Arn'].startswith(f'arn:aws:iam::{account_id}:'):
                print(p['PolicyName'])
    else:
        print(f"Não existe a policy {policy_name}")
else:
    print("Código não executado")