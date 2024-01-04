#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("LOG GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
log_group_name = "logGroupTest1"

resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço CloudWatch")
    client = boto3.client('logs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o log group de nome {log_group_name}")
    log_groups = client.describe_log_groups(logGroupNamePrefix=log_group_name)['logGroups']
    if log_groups:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o log group de nome {log_group_name}")
        print(log_groups[0]['logGroupName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os log groups existentes")
        all_log_groups = client.describe_log_groups()['logGroups']
        for group in all_log_groups:
            print(group['logGroupName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o log group de nome {log_group_name}")
        client.create_log_group(logGroupName=log_group_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o log group de nome {log_group_name}")
        print(client.describe_log_groups(logGroupNamePrefix=log_group_name)['logGroups'][0]['logGroupName'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("LOG GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
log_group_name = "logGroupTest1"

resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço CloudWatch")
    client = boto3.client('logs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o log group de nome {log_group_name}")
    log_groups = client.describe_log_groups(logGroupNamePrefix=log_group_name)['logGroups']
    if log_groups:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os log groups existentes")
        all_log_groups = client.describe_log_groups()['logGroups']
        for group in all_log_groups:
            print(group['logGroupName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o log group de nome {log_group_name}")
        client.delete_log_group(logGroupName=log_group_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os log groups existentes")
        all_log_groups = client.describe_log_groups()['logGroups']
        for group in all_log_groups:
            print(group['logGroupName'])
    else:
        print(f"Não existe o log group de nome {log_group_name}")
else:
    print("Código não executado")