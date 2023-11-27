#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER KEY ACCESS CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "UserTest"
key_access_file = "keyAccessTest.json"
key_access_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/python/.default/secrets"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe chave de acesso para o usuário do IAM {iam_user_name}")
    access_keys = iam_client.list_access_keys(UserName=iam_user_name)['AccessKeyMetadata']

    if access_keys:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe uma chave de acesso criada para o usuário do IAM {iam_user_name}")
        for key in access_keys:
            print(f"AccessKeyId: {key['AccessKeyId']}")
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as chaves de acesso criadas do usuário do IAM {iam_user_name}")
        for key in access_keys:
            print(f"AccessKeyId: {key['AccessKeyId']}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando uma chave de acesso para o usuário do IAM {iam_user_name}")
        response = iam_client.create_access_key(UserName=iam_user_name)
        access_key = response['AccessKey']

        with open(f"{key_access_path}/{key_access_file}", "w") as key_file:
            key_file.write(f"AccessKeyId: {access_key['AccessKeyId']}\nSecretAccessKey: {access_key['SecretAccessKey']}\n")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as chaves de acesso do usuário do IAM {iam_user_name}")
        access_keys = iam_client.list_access_keys(UserName=iam_user_name)['AccessKeyMetadata']
        for key in access_keys:
            print(f"AccessKeyId: {key['AccessKeyId']}")
else:
    print("Código não executado")
                                    



# !/usr/bin/env python

import boto3
import os

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER KEY ACCESS EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "UserTest"
key_access_file = "keyAccessTest.json"
key_access_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/python/.default/secrets"
# key_access_id = "AKIAQCPZALZ6WNXS6ZEJ"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe chave de acesso para o usuário do IAM {iam_user_name}")
    access_keys = iam_client.list_access_keys(UserName=iam_user_name)['AccessKeyMetadata']

    if len(access_keys) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as chaves de acesso cridadas do usuário do IAM {iam_user_name}")
        print(access_keys)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo Id da primeira chave de acesso existente")
        key_access_id = access_keys[0]['AccessKeyId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a chave de acesso do usuário do IAM {iam_user_name}")
        iam_client.delete_access_key(UserName=iam_user_name, AccessKeyId=key_access_id)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o arquivo de chave de acesso {key_access_file}")
        key_access_file_path = os.path.join(key_access_path, key_access_file)
        if os.path.isfile(key_access_file_path):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o arquivo de chave de acesso {key_access_file}")
            os.remove(key_access_file_path)
        else:
            print(f"Não existe o arquivo de chave de acesso {key_access_file}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as chaves de acesso cridadas do usuário do IAM {iam_user_name}")
        access_keys_after_deletion = iam_client.list_access_keys(UserName=iam_user_name)['AccessKeyMetadata']
        print(access_keys_after_deletion)
    else:
        print(f"Não existe o usuário do IAM de nome {iam_user_name}")
else:
    print("Código não executado")