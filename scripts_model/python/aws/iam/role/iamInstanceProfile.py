#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM INSTANCE PROFILE CREATION AND ADD ROLE")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
instance_profile_name = "instanceProfileTest"
role_name = "roleServiceTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o perfil de instância de nome {instance_profile_name}")
    instance_profiles = iam_client.list_instance_profiles()['InstanceProfiles']
    instance_profile_names = [profile['InstanceProfileName'] for profile in instance_profiles]

    if instance_profile_name in instance_profile_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o perfil de instância de nome {instance_profile_name}")
        print(instance_profile_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os perfis de instância existentes")
        print("\n".join(instance_profile_names))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o perfil de instância de nome {instance_profile_name}")
        iam_client.create_instance_profile(InstanceProfileName=instance_profile_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Adicionando a role {role_name} ao perfil de instância de nome {instance_profile_name}")
        iam_client.add_role_to_instance_profile(InstanceProfileName=instance_profile_name, RoleName=role_name)
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o perfil de instância de nome {instance_profile_name}")
        print(instance_profile_name)
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM INSTANCE PROFILE EXCLUSION AND REMOVE ROLE")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
instance_profile_name = "instanceProfileTest"
role_name = "roleServiceTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o perfil de instância de nome {instance_profile_name}")
    instance_profiles = iam_client.list_instance_profiles()['InstanceProfiles']
    instance_profile_names = [profile['InstanceProfileName'] for profile in instance_profiles]

    if instance_profile_name in instance_profile_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os perfis de instância existentes")
        print("\n".join(instance_profile_names))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a role {role_name} do perfil de instância de nome {instance_profile_name}")
        iam_client.remove_role_from_instance_profile(InstanceProfileName=instance_profile_name, RoleName=role_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o perfil de instância de nome {instance_profile_name}")
        iam_client.delete_instance_profile(InstanceProfileName=instance_profile_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os perfis de instância existentes")
        instance_profiles_after_deletion = iam_client.list_instance_profiles()['InstanceProfiles']
        instance_profile_names_after_deletion = [profile['InstanceProfileName'] for profile in instance_profiles_after_deletion]
        print("\n".join(instance_profile_names_after_deletion))
    else:
        print(f"Não existe o perfil de instância de nome {instance_profile_name}")
else:
    print("Código não executado")