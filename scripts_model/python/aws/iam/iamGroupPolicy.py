#!/usr/bin/env python
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM GROUP ADD POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "iamGroupTest"
policy_name = "AdministratorAccess"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a policy {policy_name} no grupo {iam_group_name}")
        attached_policies = iam_client.list_attached_group_policies(GroupName=iam_group_name)['AttachedPolicies']
        
        if any(policy['PolicyName'] == policy_name for policy in attached_policies):
            print(f"-----//-----//-----//-----//-----//-----//-----\n"
                  f"Já existe a policy {policy_name} no grupo {iam_group_name}")
            for policy in attached_policies:
                print(f"PolicyName: {policy['PolicyName']}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as policies do grupo {iam_group_name}")
            for policy in attached_policies:
                print(f"PolicyName: {policy['PolicyName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ARN da policy {policy_name}")
            response = iam_client.list_policies(Scope='All')
            policy_arn = next((policy['Arn'] for policy in response.get('Policies', []) if policy['PolicyName'] == policy_name), None)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Adicionando a policy {policy_name} ao grupo {iam_group_name}")
            iam_client.attach_group_policy(GroupName=iam_group_name, PolicyArn=policy_arn)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a policy {policy_name} do grupo {iam_group_name}")
            attached_policies = iam_client.list_attached_group_policies(GroupName=iam_group_name)['AttachedPolicies']
            for policy in attached_policies:
                print(f"PolicyName: {policy['PolicyName']}")
    except iam_client.exceptions.NoSuchEntityException:
        print("Ocorreu um erro ao verificar as policies.")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM GROUP REMOVE POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_group_name = "iamGroupTest"
policy_name = "AdministratorAccess"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a policy {policy_name} no grupo {iam_group_name}")
    attached_policies = iam_client.list_attached_group_policies(GroupName=iam_group_name)['AttachedPolicies']
    matching_policies = [p for p in attached_policies if p['PolicyName'] == policy_name]

    if matching_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as policies do grupo antes da remoção:")
        for attached_policy in attached_policies:
            print(attached_policy['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da policy {policy_name}")
        policy_arn = matching_policies[0]['PolicyArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a policy {policy_name} do grupo {iam_group_name}")
        iam_client.detach_group_policy(GroupName=iam_group_name, PolicyArn=policy_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as policies do grupo após a remoção:")
        attached_policies_after_removal = iam_client.list_attached_group_policies(GroupName=iam_group_name)['AttachedPolicies']
        for attached_policy_after_removal in attached_policies_after_removal:
            print(attached_policy_after_removal['PolicyName'])
    else:
        print(f"Não existe a policy {policy_name} no grupo {iam_group_name}")
else:
    print("Código não executado")