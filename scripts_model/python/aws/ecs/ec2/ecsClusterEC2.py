#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CLUSTER EC2 CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterEC2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs')
    
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name} (Ignorando erro)...")
    try:
        response = ecs_client.describe_clusters(clusters=[cluster_name])
        condition = response['clusters'][0]['status']
    except ecs_client.exceptions.ClusterNotFoundException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    excluded_status = ["ACTIVE", "CREATING", 0]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o cluster de nome {cluster_name}")
        print(response['clusters'][0]['clusterName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        cluster_arns = ecs_client.list_clusters()['clusterArns']
        print(cluster_arns)
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cluster de nome {cluster_name}")
        ecs_client.create_cluster(
            clusterName=cluster_name,
            settings=[{'name': 'containerInsights', 'value': 'enabled'}]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o cluster de nome {cluster_name}")
        response = ecs_client.describe_clusters(clusters=[cluster_name])
        print(f"Nome: {response['clusters'][0]['clusterName']}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CLUSTER EC2 EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterEC2Test1"
log_group_name = f"/aws/ecs/containerinsights/{cluster_name}/performance"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS e outro para o serviço CloudWatch")
    ecs_client = boto3.client('ecs')
    logs_client = boto3.client('logs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name} (Ignorando erro)...")
    try:
        response = ecs_client.describe_clusters(clusters=[cluster_name])
        condition = response['clusters'][0]['status']
    except ecs_client.exceptions.ClusterNotFoundException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    excluded_status = ["ACTIVE", "CREATING", 0]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        cluster_arns = ecs_client.list_clusters()['clusterArns']
        print(cluster_arns)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o cluster de nome {cluster_name}")
        ecs_client.delete_cluster(cluster=cluster_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o log group de nome {log_group_name}")
        log_group_response = logs_client.describe_log_groups(logGroupNamePrefix=log_group_name)
        if len(log_group_response['logGroups']) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o log group de nome {log_group_name}")
            logs_client.delete_log_group(logGroupName=log_group_name)
        else:
            print(f"Não existe o log group de nome {log_group_name}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        cluster_arns = ecs_client.list_clusters()['clusterArns']
        print(cluster_arns)
    else:
        print(f"Não existe o cluster de nome {cluster_name}")
else:
    print("Código não executado")