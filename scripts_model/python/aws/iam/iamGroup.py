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
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o grupo de nome {iam_group_name}")
        groups = iam_client.list_groups(PathPrefix='/')['Groups']

        if any(group['GroupName'] == iam_group_name for group in groups):
            print(f"-----//-----//-----//-----//-----//-----//-----\n"
                  f"Já existe o grupo de nome {iam_group_name}")
            for group in groups:
                print(f"GroupName: {group['GroupName']}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todos os grupos criados")
            for group in groups:
                print(f"GroupName: {group['GroupName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o grupo de nome {iam_group_name}")
            iam_client.create_group(GroupName=iam_group_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o grupo de nome {iam_group_name}")
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
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o grupo de nome {iam_group_name}")
        groups = iam_client.list_groups(PathPrefix='/')['Groups']
        if any(group['GroupName'] == iam_group_name for group in groups):
            print(f"-----//-----//-----//-----//-----//-----//-----\n"
                  f"Listando todos os grupos criados")
            for group in groups:
                print(f"GroupName: {group['GroupName']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o grupo de nome {iam_group_name}")
            iam_client.delete_group(GroupName=iam_group_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os grupos criados")
            groups = iam_client.list_groups(PathPrefix='/')['Groups']
            for group in groups:
                print(f"GroupName: {group['GroupName']}")
        else:
            print(f"Não existe o grupo de nome {iam_group_name}")
    except iam_client.exceptions.NoSuchEntityException:
        print("Ocorreu um erro ao verificar os grupos.")
else:
    print("Código não executado")