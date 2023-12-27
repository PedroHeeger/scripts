#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CLUSTER FARGATE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterFargateTest1"
capacity_provider_name = "FARGATE"
region = "us-east-1"
account_id = "001727357081"
cluster_arn = f"arn:aws:ecs:{region}:{account_id}:cluster/{cluster_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs', region_name=region)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    clusters = ecs_client.list_clusters()
    if cluster_arn in clusters['clusterArns']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o cluster de nome {cluster_name}")
        response = ecs_client.describe_clusters(clusters=[cluster_arn])
        print(response['clusters'][0]['clusterName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        cluster_arns = ecs_client.list_clusters()['clusterArns']
        print("\n".join(cluster_arns))
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cluster de nome {cluster_name}")
        ecs_client.create_cluster(
            clusterName=cluster_name,
            settings=[{'name': 'containerInsights', 'value': 'enabled'}],
            capacityProviders=[capacity_provider_name],
            defaultCapacityProviderStrategy=[{'capacityProvider': capacity_provider_name, 'weight': 1}]
        )
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o cluster de nome {cluster_name}")
        response = ecs_client.describe_clusters(clusters=[cluster_arn])
        print(response['clusters'][0]['clusterName'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CLUSTER FARGATE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterFargateTest1"
region = "us-east-1"
account_id = "001727357081"
cluster_arn = f"arn:aws:ecs:{region}:{account_id}:cluster/{cluster_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    clusters = ecs_client.list_clusters()['clusterArns']

    if len(clusters) > 0 and cluster_arn in clusters[0]:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        print(clusters)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o cluster de nome {cluster_name}")
        ecs_client.delete_cluster(
            cluster=cluster_name
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        clusters = ecs_client.list_clusters()['clusterArns']
        print(clusters)
    else:
        print(f"Não existe o cluster de nome {cluster_name}")
else:
    print("Código não executado")