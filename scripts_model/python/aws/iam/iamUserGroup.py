#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER ADD GROUP")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "GroupTest"
iam_user_name = "UserTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM {iam_user_name} no grupo {iam_group_name}")
        group_users = iam_client.get_group(GroupName=iam_group_name)['Users']

        if any(user['UserName'] == iam_user_name for user in group_users):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe um usuário do IAM de nome {iam_user_name} no grupo {iam_group_name}")
            for user in group_users:
                print(f"UserName: {user['UserName']}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os usuários do IAM do grupo {iam_group_name}")
            for user in group_users:
                print(f"UserName: {user['UserName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Adicionando o usuário do IAM de nome {iam_user_name} ao grupo {iam_group_name}")
            iam_client.add_user_to_group(UserName=iam_user_name, GroupName=iam_group_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o usuário de nome {iam_user_name} no grupo {iam_group_name}")
            group_users = iam_client.get_group(GroupName=iam_group_name)['Users']
            for user in group_users:
                print(f"UserName: {user['UserName']}")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"O grupo {iam_group_name} não existe.")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER REMOVE GROUP")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "GroupTest"
iam_user_name = "UserTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM {iam_user_name} no grupo {iam_group_name}")
        group_users = iam_client.get_group(GroupName=iam_group_name)['Users']
        if any(user['UserName'] == iam_user_name for user in group_users):
            print(f"-----//-----//-----//-----//-----//-----//-----\n"
                  f"Listando todos os usuários do IAM do grupo {iam_group_name}")
            for user in group_users:
                print(f"UserName: {user['UserName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o usuário do IAM {iam_user_name} do grupo {iam_group_name}")
            iam_client.remove_user_from_group(UserName=iam_user_name, GroupName=iam_group_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os usuários do IAM do grupo {iam_group_name}")
            group_users = iam_client.get_group(GroupName=iam_group_name)['Users']
            for user in group_users:
                print(f"UserName: {user['UserName']}")
        else:
            print(f"Não existe o usuário do IAM {iam_user_name} no grupo {iam_group_name}")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"O grupo {iam_group_name} não existe.")
else:
    print("Código não executado")