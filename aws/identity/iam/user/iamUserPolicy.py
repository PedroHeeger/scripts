#!/usr/bin/env python3

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER ADD POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"
policy_name = "AmazonS3FullAccess3"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ").strip().lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o usuário do IAM {iam_user_name} e a policy {policy_name}")
    iam_client = boto3.client('iam')
    users = iam_client.list_users()['Users']
    policies = iam_client.list_policies(Scope='All', MaxItems=1000)['Policies']
    if any(user['UserName'] == iam_user_name for user in users) and any(policy['PolicyName'] == policy_name for policy in policies):

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a policy {policy_name} no usuário {iam_user_name}")
        attached_policies = iam_client.list_attached_user_policies(UserName=iam_user_name)['AttachedPolicies']
        attached_policy_names = [policy['PolicyName'] for policy in attached_policies]

        if policy_name in attached_policy_names:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe a policy {policy_name} no usuário {iam_user_name}")
            print('\n'.join(attached_policy_names))
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as policies do usuário {iam_user_name}")
            print('\n'.join(attached_policy_names))

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ARN da policy {policy_name}")
            response = iam_client.list_policies(Scope='All', MaxItems=1000)
            policy_arn = next((policy['Arn'] for policy in response.get('Policies', []) if policy['PolicyName'] == policy_name), None)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Adicionando a policy {policy_name} ao usuário {iam_user_name}")
            iam_client.attach_user_policy(UserName=iam_user_name, PolicyArn=policy_arn)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a policy {policy_name} do usuário {iam_user_name}")
            attached_policies = iam_client.list_attached_user_policies(UserName=iam_user_name)['AttachedPolicies']
            attached_policy_names = [policy['PolicyName'] for policy in attached_policies]
            print('\n'.join(attached_policy_names))
    else:
        print(f"Não existe o usuário do IAM {iam_user_name} ou a policy {policy_name}")
else:
    print("Código não executado")




#!/usr/bin/env python3

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER REMOVE POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"
policy_name = "AmazonS3FullAccess3"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ").strip().lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o usuário do IAM {iam_user_name} e a policy {policy_name}")
    iam_client = boto3.client('iam')
    users = iam_client.list_users()['Users']
    policies = iam_client.list_policies(Scope='All', MaxItems=1000)['Policies']
    if any(user['UserName'] == iam_user_name for user in users) and any(policy['PolicyName'] == policy_name for policy in policies):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a policy {policy_name} no usuário {iam_user_name}")
        attached_policies = iam_client.list_attached_user_policies(UserName=iam_user_name)['AttachedPolicies']
        attached_policy_names = [policy['PolicyName'] for policy in attached_policies]

        if policy_name in attached_policy_names:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as policies do usuário {iam_user_name}")
            print('\n'.join(attached_policy_names))

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ARN da policy {policy_name}")
            response = iam_client.list_policies(Scope='All', MaxItems=1000)
            policy_arn = next((policy['Arn'] for policy in response.get('Policies', []) if policy['PolicyName'] == policy_name), None)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a policy {policy_name} do usuário {iam_user_name}")
            iam_client.detach_user_policy(UserName=iam_user_name, PolicyArn=policy_arn)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as policies do usuário {iam_user_name}")
            attached_policies = iam_client.list_attached_user_policies(UserName=iam_user_name)['AttachedPolicies']
            attached_policy_names = [policy['PolicyName'] for policy in attached_policies]
            print('\n'.join(attached_policy_names))
        else:
            print(f"Não existe a policy {policy_name} no usuário {iam_user_name} ou a policy {policy_name}")
    else:
        print(f"Não existe o usuário do IAM {iam_user_name} ou a policy {policy_name}")
else:
    print("Código não executado")