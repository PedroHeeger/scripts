#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EKS")
print("NODE GROUP CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterEKSTest1"
nodegroup_name = "nodeGroupTest1"
eks_nodegroup_role_name = "eksEC2Role"
ami_type = "AL2_x86_64"
instance_type = "t3.small"
disk_size = 10
min_size = 2
max_size = 2
desired_size = 2

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o node group de nome {nodegroup_name} no cluster {cluster_name} (Ignorando erro)...")
    erro = "ResourceNotFoundException"
    try:
        eks_client = boto3.client('eks')
        response = eks_client.describe_nodegroup(clusterName=cluster_name, nodegroupName=nodegroup_name)
        condition = response['nodegroup']['status']
    except eks_client.exceptions.ResourceNotFoundException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o node group de nome {nodegroup_name} no cluster {cluster_name}")
    excluded_status = ["ACTIVE", "CREATING", "UPDATING", "DELETE_FAILED", 0]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o node group de nome {nodegroup_name} no cluster {cluster_name}")
        print(response['nodegroup']['nodegroupName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os node groups do cluster {cluster_name}")
        nodegroups = eks_client.list_nodegroups(clusterName=cluster_name)['nodegroups']
        print(nodegroups)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da role {eks_nodegroup_role_name}")
        iam_client = boto3.client('iam')
        eks_nodegroup_role_arn = iam_client.get_role(RoleName=eks_nodegroup_role_name)['Role']['Arn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo os Ids dos elementos de rede")
        ec2_client = boto3.client('ec2')
        subnets = ec2_client.describe_subnets()['Subnets']
        subnet_ids = [subnet['SubnetId'] for subnet in subnets]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um node group de nome {nodegroup_name} no cluster {cluster_name}")
        eks_client.create_nodegroup(
            clusterName=cluster_name,
            nodegroupName=nodegroup_name,
            subnets=subnet_ids,
            instanceTypes=[instance_type],
            amiType=ami_type,
            diskSize=disk_size,
            nodeRole=eks_nodegroup_role_arn,
            capacityType="ON_DEMAND",
            scalingConfig={"minSize": min_size, "maxSize": max_size, "desiredSize": desired_size}
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o node group de nome {nodegroup_name} no cluster {cluster_name}")
        response = eks_client.describe_nodegroup(clusterName=cluster_name, nodegroupName=nodegroup_name)
        print(f"Nome: {response['nodegroup']['nodegroupName']}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EKS")
print("NODE GROUP EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
cluster_name = "clusterEKSTest1"
nodegroup_name = "nodeGroupTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o node group de nome {nodegroup_name} no cluster {cluster_name} (Ignorando erro)...")
    erro = "ResourceNotFoundException"
    try:
        eks_client = boto3.client('eks')
        response = eks_client.describe_nodegroup(clusterName=cluster_name, nodegroupName=nodegroup_name)
        condition = response['nodegroup']['status']
    except eks_client.exceptions.ResourceNotFoundException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o node group de nome {nodegroup_name} no cluster {cluster_name}")
    excluded_status = ["ACTIVE", "CREATING", "UPDATING", "DELETE_FAILED", 0]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os node groups do cluster {cluster_name}")
        nodegroups = eks_client.list_nodegroups(clusterName=cluster_name)['nodegroups']
        print(nodegroups)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o node group de nome {nodegroup_name} do cluster {cluster_name}")
        eks_client.delete_nodegroup(clusterName=cluster_name, nodegroupName=nodegroup_name)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os node groups do cluster {cluster_name}")
        nodegroups = eks_client.list_nodegroups(clusterName=cluster_name)['nodegroups']
        print(nodegroups)
    else:
        print(f"Não existe o node group de nome {nodegroup_name} no cluster {cluster_name}")
else:
    print("Código não executado")