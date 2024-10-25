#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE SERVICE ADD POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_role_name = "iamRoleTest"
policy_name = "AmazonS3ReadOnlyAccess"
policy_arn = f"arn:aws:iam::aws:policy/{policy_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role {iam_role_name} e a policy {policy_name}")
    iam_client = boto3.client('iam')
    roles = iam_client.list_roles(PathPrefix='/')['Roles']
    policies = iam_client.list_policies(Scope='All', MaxItems=1000)['Policies']
    if any(role['RoleName'] == iam_role_name for role in roles) and any(policy['PolicyName'] == policy_name for policy in policies):
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a policy {policy_name} anexada a role {iam_role_name}")
        attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name)['AttachedPolicies']
        matching_policies = [p for p in attached_policies if p['PolicyName'] == policy_name]

        if matching_policies:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe a policy {policy_name} anexada a role {iam_role_name}")
            for p in matching_policies:
                print(p['PolicyName'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as polices anexadas a role {iam_role_name}")
            attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name)['AttachedPolicies']
            for p in attached_policies:
                print(p['PolicyName'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ARN da policy {policy_name}")
            policies = iam_client.list_policies(MaxItems=1000)['Policies']
            matching_policies = [policy for policy in policies if policy['PolicyName'] == policy_name]
            policy_arn = matching_policies[0]['Arn']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Vinculando a policy {policy_name} a role {iam_role_name}")
            iam_client.attach_role_policy(RoleName=iam_role_name, PolicyArn=policy_arn)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a policy {policy_name} anexada a role {iam_role_name}")
            attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name)['AttachedPolicies']
            for p in attached_policies:
                if p['PolicyName'] == policy_name:
                    print(p['PolicyName'])
    else:
        print(f"Não existe a role {iam_role_name} ou a policy {policy_name}")                
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM ROLE SERVICE REMOVE POLICY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_role_name = "iamRoleTest"
policy_name = "AmazonS3ReadOnlyAccess"
policy_arn = f"arn:aws:iam::aws:policy/{policy_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role {iam_role_name} e a policy {policy_name}")
    iam_client = boto3.client('iam')
    roles = iam_client.list_roles(PathPrefix='/')['Roles']
    policies = iam_client.list_policies(Scope='All', MaxItems=1000)['Policies']
    if any(role['RoleName'] == iam_role_name for role in roles) and any(policy['PolicyName'] == policy_name for policy in policies):
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a policy {policy_name} anexada a role {iam_role_name}")
        attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name)['AttachedPolicies']
        matching_policies = [p for p in attached_policies if p['PolicyName'] == policy_name]

        if matching_policies:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as polices anexadas a role {iam_role_name}")
            attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name)['AttachedPolicies']
            for p in attached_policies:
                print(p['PolicyName'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ARN da policy {policy_name}")
            policies = iam_client.list_policies(MaxItems=1000)['Policies']
            matching_policies = [policy for policy in policies if policy['PolicyName'] == policy_name]
            policy_arn = matching_policies[0]['Arn']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a policy {policy_name} da role {iam_role_name}")
            iam_client.detach_role_policy(RoleName=iam_role_name, PolicyArn=policy_arn)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as polices anexadas a role {iam_role_name}")
            attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name)['AttachedPolicies']
            for p in attached_policies:
                print(p['PolicyName'])
        else:
            print(f"Não existe a policy {policy_name} anexada a role {iam_role_name}")
    else:
        print(f"Não existe a policy {policy_name} anexada a role {iam_role_name}")
else:
    print("Código não executado")