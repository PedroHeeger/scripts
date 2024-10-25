#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER ADD GROUP")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "iamGroupTest"
iam_user_name = "iamUserTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o grupo {iam_group_name} e o usuário do IAM {iam_user_name}")
    iam_client = boto3.client('iam')
    groups = iam_client.list_groups(PathPrefix='/')['Groups']
    users = iam_client.list_users()['Users']
    if any(group['GroupName'] == iam_group_name for group in groups) and any(user['UserName'] == iam_user_name for user in users):

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM {iam_user_name} no grupo {iam_group_name}")
        iam_client = boto3.client('iam')
        group_users = iam_client.get_group(GroupName=iam_group_name)['Users']

        if any(user['UserName'] == iam_user_name for user in group_users):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o usuário do IAM {iam_user_name} no grupo {iam_group_name}")
            for user in group_users:
                print(f"UserName: {user['UserName']}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os usuários do IAM do grupo {iam_group_name}")
            for user in group_users:
                print(f"UserName: {user['UserName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Adicionando o usuário do IAM {iam_user_name} ao grupo {iam_group_name}")
            iam_client.add_user_to_group(UserName=iam_user_name, GroupName=iam_group_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o usuário {iam_user_name} no grupo {iam_group_name}")
            group_users = iam_client.get_group(GroupName=iam_group_name)['Users']
            for user in group_users:
                print(f"UserName: {user['UserName']}")
    else:
        print(f"Não existe o grupo {iam_group_name} ou o usuário do IAM {iam_user_name}")
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER REMOVE GROUP")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "iamGroupTest"
iam_user_name = "iamUserTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o grupo {iam_group_name} e o usuário do IAM {iam_user_name}")
    iam_client = boto3.client('iam')
    groups = iam_client.list_groups(PathPrefix='/')['Groups']
    users = iam_client.list_users()['Users']
    if any(group['GroupName'] == iam_group_name for group in groups) and any(user['UserName'] == iam_user_name for user in users):

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM {iam_user_name} no grupo {iam_group_name}")
        iam_client = boto3.client('iam')
        group_users = iam_client.get_group(GroupName=iam_group_name)['Users']
        if any(user['UserName'] == iam_user_name for user in group_users):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os usuários do IAM do grupo {iam_group_name}")
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
    else:
        print(f"Não existe o grupo {iam_group_name} ou o usuário do IAM {iam_user_name}")
else:
    print("Código não executado")