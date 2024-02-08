#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CLUSTER EC2 CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterEC2Test1"
region = "us-east-1"
account_id = "001727357081"
cluster_arn = f"arn:aws:ecs:{region}:{account_id}:cluster/{cluster_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs', region_name=region)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    clusters = ecs_client.list_clusters()
    if cluster_arn in clusters['clusterArns']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se o cluster de nome {cluster_name} está ativo")
        cluster_status = ecs_client.describe_clusters(clusters=[cluster_arn])['clusters'][0]['status']
        if cluster_status == 'ACTIVE':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o cluster de nome {cluster_name}")
            print(ecs_client.describe_clusters(clusters=[cluster_arn])['clusters'][0]['clusterName'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando as ARNs de todos os clusters criados")
            cluster_arns = ecs_client.list_clusters()['clusterArns']
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando um cluster de nome {cluster_name}")
            ecs_client.create_cluster(clusterName=cluster_name, settings=[{'name': 'containerInsights', 'value': 'enabled'}])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o cluster de nome {cluster_name}")
            print(ecs_client.describe_clusters(clusters=[cluster_arn])['clusters'][0]['clusterName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se o cluster de nome {cluster_name} está ativo")
        cluster_status = ecs_client.describe_clusters(clusters=[cluster_arn])['clusters'][0]['status']
        if cluster_status == 'ACTIVE':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o cluster de nome {cluster_name}")
            print(ecs_client.describe_clusters(clusters=[cluster_arn])['clusters'][0]['clusterName'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando as ARNs de todos os clusters criados")
            cluster_arns = ecs_client.list_clusters()['clusterArns']
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando um cluster de nome {cluster_name}")
            ecs_client.create_cluster(clusterName=cluster_name, settings=[{'name': 'containerInsights', 'value': 'enabled'}])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o cluster de nome {cluster_name}")
            print(ecs_client.describe_clusters(clusters=[cluster_arn])['clusters'][0]['clusterName'])
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
region = "us-east-1"
account_id = "001727357081"
cluster_arn = f"arn:aws:ecs:{region}:{account_id}:cluster/{cluster_name}"
log_group_name = f"/aws/ecs/containerinsights/{cluster_name}/performance"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS e outro para Logs do CloudWatch")
    ecs_client = boto3.client('ecs', region_name=region)
    logs_client = boto3.client('logs', region_name=region)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    clusters = ecs_client.list_clusters()
    if cluster_arn in clusters['clusterArns']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se o cluster de nome {cluster_name} está ativo")
        cluster_status = ecs_client.describe_clusters(clusters=[cluster_arn])['clusters'][0]['status']
        if cluster_status == 'ACTIVE':
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando as ARNs de todos os clusters criados")
            cluster_arns = ecs_client.list_clusters()['clusterArns']
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o cluster de nome {cluster_name}")
            ecs_client.delete_cluster(cluster=cluster_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o log group de nome {log_group_name}")
            log_groups = logs_client.describe_log_groups(logGroupNamePrefix=log_group_name)['logGroups']
            if log_groups:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo o log group de nome {log_group_name}")
                logs_client.delete_log_group(logGroupName=log_group_name)
            else:
                print(f"Não existe o log group de nome {log_group_name}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando as ARNs de todos os clusters criados")
            ecs_client.list_clusters()['clusterArns']
        else:
            print(f"O cluster de nome {cluster_name} não está ativo")
    else:
        print(f"Não existe o cluster de nome {cluster_name}")
else:
    print("Código não executado")