#!/usr/bin/env python
import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"
role_name = "roleNameTest"
path_trust_policy_document = "G:\\Meu Drive\\4_PROJ\\scripts\\scripts_model\\.default\\aws\\iamTrustPolicy.json"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role de nome {role_name}")
    try:
        role = iam.get_role(RoleName=role_name)
        print(f"-----//-----//-----//-----//-----//-----//-----\nJá existe uma role de nome {role_name}\n{role}")
    except iam.exceptions.NoSuchEntityException:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        roles = iam.list_roles()['Roles']
        for r in roles:
            print(r['RoleName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a role de nome {role_name}")

        # Carrega o documento de política de confiança
        trust_policy_document = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"AWS": f"arn:aws:iam::001727357081:user/{iam_user_name}"},
                    "Action": "sts:AssumeRole"
                }
            ]
        }

        # Cria a role
        iam.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy_document)
        )

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando a role de nome {role_name} com um arquivo JSON")

        # # Carrega o documento de política de confiança do arquivo JSON
        # with open(path_trust_policy_document, 'r') as trust_policy_file:
        #     trust_policy_document = json.load(trust_policy_file)

        # # Cria a role
        # iam.create_role(
        #     RoleName=role_name,
        #     AssumeRolePolicyDocument=json.dumps(trust_policy_document)
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a role de nome {role_name}")
        role = iam.get_role(RoleName=role_name)['Role']['RoleName']
        print(role)
else:
    print("Código não executado")




#!/usr/bin/env python
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"
role_name = "roleNameTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role de nome {role_name}")
    try:
        role = iam.get_role(RoleName=role_name)
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        roles = iam.list_roles()['Roles']
        for r in roles:
            print(r['RoleName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a role de nome {role_name}")
        iam.delete_role(RoleName=role_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as roles criadas")
        roles = iam.list_roles()['Roles']
        for r in roles:
            print(r['RoleName'])
    except iam.exceptions.NoSuchEntityException:
        print(f"-----//-----//-----//-----//-----//-----//-----\nNão existe a role de nome {role_name}")
else:
    print("Código não executado")