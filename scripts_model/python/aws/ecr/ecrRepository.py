#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ECR")
print("REPOSITORY CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
repository_name = "repository_test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECR")
    ecr_client = boto3.client('ecr')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o repositório de nome {repository_name}")
        repositories = ecr_client.describe_repositories(repositoryNames=[repository_name])['repositories']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o repositório de nome {repository_name}")
        print(repositories[0]['repositoryName'])

    except ClientError as e:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os repositórios criados")
        all_repositories = ecr_client.describe_repositories()['repositories']
        for repo in all_repositories:
            print(repo['repositoryName'])
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um repositório de nome {repository_name}")
        ecr_client.create_repository(repositoryName=repository_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o repositório de nome {repository_name}")
        repository = ecr_client.describe_repositories(repositoryNames=[repository_name])['repositories'][0]
        print(repository['repositoryName'])
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS ECR")
print("REPOSITORY EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
repository_name = "repository_test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECR")
    ecr_client = boto3.client('ecr')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o repositório de nome {repository_name}")
        repositories = ecr_client.describe_repositories(repositoryNames=[repository_name])['repositories']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os repositórios criados")
        all_repositories = ecr_client.describe_repositories()['repositories']
        for repo in all_repositories:
            print(repo['repositoryName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o repositório de nome {repository_name}")
        ecr_client.delete_repository(repositoryName=repository_name, force=True)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os repositórios criados")
        all_repositories_after_deletion = ecr_client.describe_repositories()['repositories']
        for repo in all_repositories_after_deletion:
            print(repo['repositoryName'])
    except ClientError as e:
        print(f"Não existe o repositório de nome {repository_name}")
else:
    print("Código não executado")