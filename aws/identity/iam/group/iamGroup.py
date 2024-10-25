#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "iamGroupTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o grupo {iam_group_name}")
        iam_client = boto3.client('iam')
        groups = iam_client.list_groups(PathPrefix='/')['Groups']

        if any(group['GroupName'] == iam_group_name for group in groups):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o grupo {iam_group_name}")
            print(f"GroupName: {iam_group_name}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todos os grupos criados")
            for group in groups:
                print(f"GroupName: {group['GroupName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o grupo {iam_group_name}")
            iam_client.create_group(GroupName=iam_group_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o grupo {iam_group_name}")
            groups = iam_client.list_groups(PathPrefix='/')['Groups']
            if any(group['GroupName'] == iam_group_name for group in groups):
                print(f"GroupName: {iam_group_name}")
    except iam_client.exceptions.NoSuchEntityException:
        print("Ocorreu um erro ao verificar os grupos.")
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM GROUP EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "iamGroupTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o grupo {iam_group_name}")
        iam_client = boto3.client('iam')
        groups = iam_client.list_groups(PathPrefix='/')['Groups']
        if any(group['GroupName'] == iam_group_name for group in groups):
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todos os grupos criados")
            for group in groups:
                print(f"GroupName: {group['GroupName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existem usuários do IAM no grupo {iam_group_name}")
            response = iam_client.get_group(GroupName=iam_group_name)
            users = response['Users']
            if len(users) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Separando os usuários do grupo {iam_group_name} em uma lista")
                user_names = [user['UserName'] for user in users]

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo os usuários do grupo {iam_group_name}")
                for user_name in user_names:
                    iam_client.remove_user_from_group(GroupName=iam_group_name, UserName=user_name)
            else:
                print(f"Não existem usuários do IAM no grupo {iam_group_name}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existem policies no grupo {iam_group_name}")
            response = iam_client.list_attached_group_policies(GroupName=iam_group_name)
            attached_policies = response['AttachedPolicies']
            if len(attached_policies) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Separando as policies do grupo {iam_group_name} em uma lista")
                policy_names = [policy['PolicyName'] for policy in attached_policies]

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo as policies do grupo {iam_group_name}")
                for policy_name in policy_names:
                    policy_response = iam_client.list_policies(Scope='All', MaxItems=1000) # O MaxItems tem o limite de 1000 policies. Contudo existem 1240 polcies, se policy procurada não estiver entre as 1000 encontradas, o valor será None e a política não será removida, impedido a remoção do grupo.
                    policy_arn = next((policy['Arn'] for policy in policy_response['Policies'] if policy['PolicyName'] == policy_name), None)
                    if policy_arn:
                        iam_client.detach_group_policy(GroupName=iam_group_name, PolicyArn=policy_arn)
            else:
                print(f"Não existem policies no grupo {iam_group_name}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o grupo {iam_group_name}")
            iam_client.delete_group(GroupName=iam_group_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os grupos criados")
            groups = iam_client.list_groups(PathPrefix='/')['Groups']
            for group in groups:
                print(f"GroupName: {group['GroupName']}")
        else:
            print(f"Não existe o grupo {iam_group_name}")
    except iam_client.exceptions.NoSuchEntityException:
        print("Ocorreu um erro ao verificar os grupos.")
else:
    print("Código não executado")