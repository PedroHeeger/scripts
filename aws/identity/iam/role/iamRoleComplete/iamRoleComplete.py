#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM INSTANCE PROFILE + ROLE + POLICY CREATION")

# Configurando as variáveis
iam_role_name = "iamRoleTest"
instance_profile_name = "instanceProfileTest"
policy_name = "AmazonS3ReadOnlyAccess"
# policy_name = "policyTest"
policy_arn = f"arn:aws:iam::aws:policy/{policy_name}"

# SERVICE:
principal = "Service"
principal_name = "ec2.amazonaws.com"

# USER:
# principal = "AWS"
# account_id = "001727357081"
# iam_user_name = "iamUserTest"
# principal_name = f"arn:aws:iam::{account_id}:user/{iam_user_name}"

# ROLE:
# principal = "AWS"
# account_id = "001727357081"
# iam_role_name2 = "iamGroupTest2"
# principal_name = f"arn:aws:iam::{account_id}:role/{iam_role_name2}"

response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    iam_client = boto3.client('iam')

    def verificar_ou_criar_perfil_de_instancia(instance_profile_name, iam_role_name):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o perfil de instância {instance_profile_name}")
        instance_profiles = iam_client.list_instance_profiles()
        if any(profile['InstanceProfileName'] == instance_profile_name for profile in instance_profiles['InstanceProfiles']):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o perfil de instância {instance_profile_name}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o perfil de instância {instance_profile_name}")
            iam_client.create_instance_profile(InstanceProfileName=instance_profile_name)
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Adicionando a role {iam_role_name} ao perfil de instância {instance_profile_name}")
            iam_client.add_role_to_instance_profile(
                InstanceProfileName=instance_profile_name,
                RoleName=iam_role_name
            )

    def vincular_policy_a_role(policy_name, iam_role_name):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da policy {policy_name}")
        policies = iam_client.list_policies(Scope='All')
        policy_arn = next((policy['Arn'] for policy in policies['Policies'] if policy['PolicyName'] == policy_name), None)
        if policy_arn:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Vinculando a policy {policy_name} à role {iam_role_name}")
            iam_client.attach_role_policy(
                RoleName=iam_role_name,
                PolicyArn=policy_arn
            )
        else:
            print(f"Policy {policy_name} não encontrada.")


    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role {iam_role_name}")
    roles = iam_client.list_roles()
    if any(role['RoleName'] == iam_role_name for role in roles['Roles']):
        verificar_ou_criar_perfil_de_instancia(instance_profile_name, iam_role_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a role {iam_role_name}")
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {principal: principal_name},
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        iam_client.create_role(
            RoleName=iam_role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy)
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a policy {policy_name}")
        policies = iam_client.list_policies(Scope='All')
        if any(policy['PolicyName'] == policy_name for policy in policies['Policies']):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe a policy {policy_name} anexada à role {iam_role_name}")
            attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name)
            if any(attached_policy['PolicyName'] == policy_name for attached_policy in attached_policies['AttachedPolicies']):
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe a policy {policy_name} anexada à role {iam_role_name}")
            else:
                vincular_policy_a_role(policy_name, iam_role_name)
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando a policy {policy_name}")
            custom_policy = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": "s3:GetObject",
                        "Resource": "arn:aws:s3:::seu-bucket/*"
                    }
                ]
            }
            iam_client.create_policy(
                PolicyName=policy_name,
                PolicyDocument=json.dumps(custom_policy)
            )
            vincular_policy_a_role(policy_name, iam_role_name)

        verificar_ou_criar_perfil_de_instancia(instance_profile_name, iam_role_name)
else:
    print("Código não executado")




#!/usr/bin/env python3

import boto3
import subprocess

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM INSTANCE PROFILE + ROLE + POLICY EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_role_name = "iamRoleTest"
instance_profile_name = "instanceProfileTest"
policy_name = "AmazonS3ReadOnlyAccess"
# policy_name = "policyTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    iam_client = boto3.client('iam')

    def remover_policies_e_role(iam_role_name):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existem policies na role {iam_role_name}")
        attached_policies = iam_client.list_attached_role_policies(RoleName=iam_role_name).get("AttachedPolicies", [])
        
        if attached_policies:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Separando as policies da role {iam_role_name} em uma lista")
            policy_arns = [policy['PolicyArn'] for policy in attached_policies]
            
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo as policies da role {iam_role_name}")
            for policy_arn in policy_arns:
                iam_client.detach_role_policy(RoleName=iam_role_name, PolicyArn=policy_arn)
        else:
            print(f"Não existem policies na role {iam_role_name}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a role {iam_role_name}")
        iam_client.delete_role(RoleName=iam_role_name)

    
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a role {iam_role_name}")
    role_exists = any(role['RoleName'] == iam_role_name for role in iam_client.list_roles().get('Roles', []))
    if role_exists:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o perfil de instância {instance_profile_name}")
        instance_profiles = iam_client.list_instance_profiles().get('InstanceProfiles', [])
        instance_profile_exists = any(profile['InstanceProfileName'] == instance_profile_name for profile in instance_profiles)

        if instance_profile_exists:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a role {iam_role_name} do perfil de instância {instance_profile_name}")
            iam_client.remove_role_from_instance_profile(InstanceProfileName=instance_profile_name, RoleName=iam_role_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o perfil de instância {instance_profile_name}")
            iam_client.delete_instance_profile(InstanceProfileName=instance_profile_name)

            remover_policies_e_role(iam_role_name)
        else:
            remover_policies_e_role(iam_role_name)
    else:
        print(f"Não existe a role {iam_role_name}")
else:
    print("Código não executado")