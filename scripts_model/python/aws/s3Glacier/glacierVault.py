#!/usr/bin/env python3

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3 GLACIER")
print("VAULT CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
vault_name = "vaultTest1"
account_id = "-"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ").strip().lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cofre de nome {vault_name}")
    glacier_client = boto3.client('glacier')
    vaults = glacier_client.list_vaults(accountId=account_id)['VaultList']
    existing_vaults = [vault['VaultName'] for vault in vaults]

    if vault_name in existing_vaults:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o cofre de nome {vault_name}")
        print(vault_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os cofres da conta determinada")
        print('\n'.join(existing_vaults))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o cofre de nome {vault_name}")
        glacier_client.create_vault(accountId=account_id, vaultName=vault_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o cofre de nome {vault_name}")
        vaults = glacier_client.list_vaults(accountId=account_id)['VaultList']
        existing_vaults = [vault['VaultName'] for vault in vaults]
        print(vault_name if vault_name in existing_vaults else "Não encontrado")
else:
    print("Código não executado")




#!/usr/bin/env python3

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3 GLACIER")
print("VAULT EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
vault_name = "vaultEdn1"
account_id = "-"

response = input("Deseja executar o código? (y/n) ").strip().lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cofre de nome {vault_name}")
    glacier_client = boto3.client('glacier')
    vaults = glacier_client.list_vaults(accountId=account_id)['VaultList']
    existing_vaults = [vault['VaultName'] for vault in vaults]

    if vault_name in existing_vaults:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os cofres da conta determinada")
        print('\n'.join(existing_vaults))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o cofre de nome {vault_name}")
        glacier_client.delete_vault(accountId=account_id, vaultName=vault_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os cofres da conta determinada")
        vaults = glacier_client.list_vaults(accountId=account_id)['VaultList']
        existing_vaults = [vault['VaultName'] for vault in vaults]
        print('\n'.join(existing_vaults))
    else:
        print(f"Não existe o cofre de nome {vault_name}")
else:
    print("Código não executado")