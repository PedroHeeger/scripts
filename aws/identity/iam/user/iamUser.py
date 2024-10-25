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
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM {iam_user_name}")
        iam_client = boto3.client('iam')
        user = iam_client.get_user(UserName=iam_user_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe um usuário do IAM {iam_user_name}")
        print(f"UserName: {user['User']['UserName']}")
        
    except iam_client.exceptions.NoSuchEntityException:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os usuários do IAM criados")
        users = iam_client.list_users()
        for user in users['Users']:
            print(f"UserName: {user['UserName']}")
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o usuário do IAM {iam_user_name}")
        iam_client.create_user(UserName=iam_user_name)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um perfil de login do usuário do IAM {iam_user_name}")
        iam_client.create_login_profile(UserName=iam_user_name, Password=user_password)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o usuário do IAM {iam_user_name}")
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
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o usuário do IAM {iam_user_name}")
        iam_client = boto3.client('iam')
        user = iam_client.get_user(UserName=iam_user_name)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os usuários do IAM criados")
        users = iam_client.list_users()
        for user in users['Users']:
            print(f"UserName: {user['UserName']}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando quais grupos o usuário do IAM {iam_user_name} está inserido")
        response = iam_client.list_groups_for_user(UserName=iam_user_name)
        groups = response['Groups']

        if len(groups) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Separando os grupos do usuário do IAM {iam_user_name} em uma lista")
            group_names = [group['GroupName'] for group in groups]

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o usuário do IAM {iam_user_name} dos grupos")
            for group_name in group_names:
                iam_client.remove_user_from_group(GroupName=group_name, UserName=iam_user_name)
        else:
            print(f"Não existem grupos que o usuário do IAM {iam_user_name} faça parte")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existem policies vinculadas ao usuário do IAM {iam_user_name}")
        response = iam_client.list_attached_user_policies(UserName=iam_user_name)
        attached_policies = response['AttachedPolicies']

        if len(attached_policies) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Separando as policies do usuário do IAM {iam_user_name} em uma lista")
            policy_names = [policy['PolicyName'] for policy in attached_policies]

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo as policies do usuário do IAM {iam_user_name}")
            for policy_name in policy_names:
                policy_response = iam_client.list_policies(Scope='All', MaxItems=1000) # O MaxItems tem o limite de 1000 policies. Contudo existem 1240 polcies, se policy procurada não estiver entre as 1000 encontradas, o valor será None e a política não será removida, impedido a remoção do usuário.
                policy_arn = next((policy['Arn'] for policy in policy_response['Policies'] if policy['PolicyName'] == policy_name), None)
                if policy_arn:
                    iam_client.detach_user_policy(UserName=iam_user_name, PolicyArn=policy_arn)
        else:
            print(f"Não existem policies vinculadas ao usuário do IAM {iam_user_name}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o perfil de login do usuário do IAM {iam_user_name}")
        iam_client.delete_login_profile(UserName=iam_user_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o usuário do IAM {iam_user_name}")
        iam_client.delete_user(UserName=iam_user_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os usuários do IAM criados")
        users = iam_client.list_users()
        for user in users['Users']:
            print(f"UserName: {user['UserName']}")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"Não existe o usuário do IAM {iam_user_name}")
else:
    print("Código não executado")
