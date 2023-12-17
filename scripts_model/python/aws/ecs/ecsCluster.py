#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CLUSTER CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterTest1"
launch_type = "FARGATE"
region = "us-east-1"
account_id = "001727357081"
cluster_arn = f"arn:aws:ecs:{region}:{account_id}:cluster/{cluster_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs = boto3.client('ecs', region_name=region)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    response = ecs.list_clusters()
    if cluster_arn in response['clusterArns']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o cluster de nome {cluster_name}")
        response = ecs.describe_clusters(clusters=[cluster_arn])
        print(response['clusters'][0]['clusterName'])
        # os.path.basename(response['clusterArns'][0])
        # [cluster_arn for cluster_arn in response['clusterArns'] if cluster_arn == cluster_arn][0]
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        response = ecs.list_clusters()
        print("\n".join(response['clusterArns']))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cluster de nome {cluster_name}")
        ecs.create_cluster(
            clusterName=cluster_name,
            settings=[{'name': 'containerInsights', 'value': 'enabled'}],
            capacityProviders=[launch_type],
            defaultCapacityProviderStrategy=[{'capacityProvider': launch_type, 'weight': 1}]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o cluster de nome {cluster_name}")
        response = ecs.describe_clusters(clusters=[cluster_arn])
        print(response['clusters'][0]['clusterName'])
        # os.path.basename(response['clusterArns'][0])
        # [cluster_arn for cluster_arn in response['clusterArns'] if cluster_arn == cluster_arn][0]
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CLUSTER EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterTest1"
region = "us-east-1"
account_id = "001727357081"
cluster_arn = f"arn:aws:ecs:{region}:{account_id}:cluster/{cluster_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs = boto3.client('ecs', region_name=region)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    response = ecs.list_clusters()
    if cluster_arn in response['clusterArns']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        response = ecs.list_clusters()
        print("\n".join(response['clusterArns']))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o cluster de nome {cluster_name}")
        ecs.delete_cluster(cluster=cluster_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todos os clusters criados")
        response = ecs.list_clusters()
        print("\n".join(response['clusterArns']))
    else:
        print(f"Não existe o cluster de nome {cluster_name}")
else:
    print("Código não executado")