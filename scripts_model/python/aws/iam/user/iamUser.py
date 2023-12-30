#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"
user_password = "SenhaTest123"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')
    
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM de nome {iam_user_name}")
        user = iam_client.get_user(UserName=iam_user_name)
        print(f"Já existe um usuário do IAM de nome {iam_user_name}")
        print(f"UserName: {user['User']['UserName']}")
        
    except iam_client.exceptions.NoSuchEntityException:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os usuários do IAM criados")
        users = iam_client.list_users()
        for user in users['Users']:
            print(f"UserName: {user['UserName']}")
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o usuário do IAM de nome {iam_user_name}")
        iam_client.create_user(UserName=iam_user_name)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um perfil de login do usuário do IAM de nome {iam_user_name}")
        iam_client.create_login_profile(UserName=iam_user_name, Password=user_password)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o usuário do IAM de nome {iam_user_name}")
        user = iam_client.get_user(UserName=iam_user_name)
        print(f"UserName: {user['User']['UserName']}")
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM de nome {iam_user_name}")
        user = iam_client.get_user(UserName=iam_user_name)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os usuários do IAM criados")
        users = iam_client.list_users()
        for user in users['Users']:
            print(f"UserName: {user['UserName']}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o perfil de login do usuário do IAM de nome {iam_user_name}")
        iam_client.delete_login_profile(UserName=iam_user_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o usuário do IAM de nome {iam_user_name}")
        iam_client.delete_user(UserName=iam_user_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os usuários do IAM criados")
        users = iam_client.list_users()
        for user in users['Users']:
            print(f"UserName: {user['UserName']}")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"Não existe o usuário do IAM de nome {iam_user_name}")
else:
    print("Código não executado")
