#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM POLICY CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
policy_name = "policyTest"
policy_arn = "arn:aws:iam::001727357081:policy/policyTest"
account_id = "001727357081"
path_policy_document = "G:\\Meu Drive\\4_PROJ\\scripts\\scripts_model\\.default\\aws\\iamPolicy.json"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam = boto3.client('iam')
    
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a policy de nome {policy_name}")
    response = iam.list_policies(Scope='Local', MaxItems=1000)
    policies = response['Policies']
    
    existing_policies = [p for p in policies if p['PolicyName'] == policy_name]
    if existing_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a policy de nome {policy_name}")
        print(existing_policies[0]['Arn'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as polices criadas pelo usuário")
        for p in policies:
            if p['Arn'].startswith(f'arn:aws:iam::{account_id}:'):
                print(p['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a polciy de nome {policy_name}")
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
        # print(f"Criando a polciy de nome {policy_name} a partir do arquivo JSON")
        # # Carregando o conteúdo do arquivo JSON
        # with open(path_policy_document, 'r') as file:
        #     policy_document_content = json.load(file)

        # iam.create_policy(
        #     PolicyName=policy_name,
        #     PolicyDocument=json.dumps(policy_document_content)
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a policy de nome {policy_name}")
        response = iam.list_policies(Scope='Local', MaxItems=1000)
        policies = response['Policies']
        existing_policies = [p for p in policies if p['PolicyName'] == policy_name]
        print(existing_policies[0]['Arn'] if existing_policies else f"A policy {policy_name} não foi encontrada.")
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
# policy_name = "policyTest"
policy_name = "QBusiness-Application-147b0"
policy_arn = "arn:aws:iam::001727357081:policy/policyTest"
account_id = "001727357081"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a policy de nome {policy_name}")
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
        print(f"Extraindo o ARN da policy de nome {policy_name}")
        policy_arn = matching_policies[0]['Arn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a policy de nome {policy_name}")
        iam.delete_policy(PolicyArn=policy_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as polices criadas pelo usuário")
        policies = iam.list_policies(Scope='Local', MaxItems=1000)['Policies']
        for p in policies:
            if p['Arn'].startswith(f'arn:aws:iam::{account_id}:'):
                print(p['PolicyName'])
    else:
        print(f"Não existe a policy de nome {policy_name}")
else:
    print("Código não executado")