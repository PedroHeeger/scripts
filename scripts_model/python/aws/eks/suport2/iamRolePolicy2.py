#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE ADD POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
role_name = "eksEC2Role"
policy_name2 = "AmazonEKSWorkerNodePolicy"
policy_arn2 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a policy {policy_name2} anexada a role de nome {role_name}")
    attached_policies = iam.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']
    matching_policies = [p for p in attached_policies if p['PolicyName'] == policy_name2]

    if matching_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a policy {policy_name2} anexada a role de nome {role_name}")
        for p in matching_policies:
            print(p['PolicyName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as polices anexadas a role de nome {role_name}")
        attached_policies = iam.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']
        for p in attached_policies:
            print(p['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da policy {policy_name2}")
        policies = iam.list_policies(MaxItems=1000)['Policies']
        matching_policies = [policy for policy in policies if policy['PolicyName'] == policy_name2]
        policy_arn2 = matching_policies[0]['Arn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Vinculando a policy {policy_name2} a role de nome {role_name}")
        iam.attach_role_policy(RoleName=role_name, PolicyArn=policy_arn2)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a policy {policy_name2} anexada a role de nome {role_name}")
        attached_policies = iam.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']
        for p in attached_policies:
            if p['PolicyName'] == policy_name2:
                print(p['PolicyName'])
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE REMOVE POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
role_name = "eksEC2Role"
policy_name2 = "AmazonEKSWorkerNodePolicy"
policy_arn2 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a policy {policy_name2} anexada a role de nome {role_name}")
    attached_policies = iam.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']
    matching_policies = [p for p in attached_policies if p['PolicyName'] == policy_name2]

    if matching_policies:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as polices anexadas a role de nome {role_name}")
        attached_policies = iam.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']
        for p in attached_policies:
            print(p['PolicyName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da policy {policy_name2}")
        policies = iam.list_policies(MaxItems=1000)['Policies']
        matching_policies = [policy for policy in policies if policy['PolicyName'] == policy_name2]
        policy_arn2 = matching_policies[0]['Arn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a policy {policy_name2} da role de nome {role_name}")
        iam.detach_role_policy(RoleName=role_name, PolicyArn=policy_arn2)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as polices anexadas a role de nome {role_name}")
        attached_policies = iam.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']
        for p in attached_policies:
            print(p['PolicyName'])
    else:
        print(f"Não existe a policy {policy_name2} anexada a role de nome {role_name}")
else:
    print("Código não executado")