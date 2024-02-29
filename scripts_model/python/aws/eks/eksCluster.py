#!/usr/bin/env python

import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EKS")
print("CLUSTER CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterEKSTest1"
eks_role_name = "eksClusterRole"
sg_name = "default"
az1 = "us-east-1a"
az2 = "us-east-1b"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name} (Ignorando erro)...")
    try:
        eks_client = boto3.client('eks')
        response = eks_client.describe_cluster(name=cluster_name)
        condition = response['cluster']['status']
    except eks_client.exceptions.ResourceNotFoundException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    excluded_status = ["ACTIVE", "CREATING"]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o cluster de nome {cluster_name}")
        print(response['cluster']['name'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os clusters criados")
        clusters = eks_client.list_clusters()['clusters']
        print(clusters)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da role {eks_role_name}")
        iam_client = boto3.client('iam')
        role_response = iam_client.get_role(RoleName=eks_role_name)
        role_arn = role_response['Role']['Arn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo os Ids dos elementos de rede")
        ec2_client = boto3.client('ec2')
        sg_id = ec2_client.describe_security_groups(GroupNames=[sg_name])['SecurityGroups'][0]['GroupId']
        subnet1_id = ec2_client.describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [az1]}])['Subnets'][0]['SubnetId']
        subnet2_id = ec2_client.describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [az2]}])['Subnets'][0]['SubnetId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cluster de nome {cluster_name}")
        vpc_config = {"subnetIds": [subnet1_id, subnet2_id], "securityGroupIds": [sg_id]}
        eks_client.create_cluster(name=cluster_name, roleArn=role_arn, resourcesVpcConfig=vpc_config)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o cluster de nome {cluster_name}")
        # Aguarda até que o cluster esteja criado
        while True:
            response = eks_client.describe_cluster(name=cluster_name)
            if response['cluster']['status'] == "ACTIVE":
                break
            time.sleep(5)

        print(f"Cluster criado com sucesso. Nome: {response['cluster']['name']}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EKS")
print("CLUSTER EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterEKSTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name} (Ignorando erro)...")
    try:
        eks_client = boto3.client('eks')
        response = eks_client.describe_cluster(name=cluster_name)
        condition = response['cluster']['status']
    except eks_client.exceptions.ResourceNotFoundException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o cluster de nome {cluster_name}")
    excluded_status = ["ACTIVE", "CREATING"]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os clusters criados")
        clusters = eks_client.list_clusters()['clusters']
        print(clusters)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o cluster de nome {cluster_name}")
        eks_client.delete_cluster(name=cluster_name)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os clusters criados")
        clusters = eks_client.list_clusters()['clusters']
        print(clusters)
    else:
        print(f"Não existe o cluster de nome {cluster_name}")
else:
    print("Código não executado")