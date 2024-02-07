#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CAPACITY PROVIDER CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
capacity_provider_name = "capacityProviderTest1"
asg_name = "asgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o fornecedor de capacidade de nome {capacity_provider_name}")
    capacity_providers = ecs_client.describe_capacity_providers(
        query=f"capacityProviders[?name=='{capacity_provider_name}'].name"
    )['capacityProviders']
    if len(capacity_providers) > 1:
        print(f"-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o fornecedor de capacidade de nome {capacity_provider_name}")
        print(capacity_providers[0]['name'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os fornecedores de capacidade existentes")
        all_capacity_providers = ecs_client.describe_capacity_providers(
            query="capacityProviders[].name[]"
        )['capacityProviders']
        print('\n'.join(all_capacity_providers))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do auto scaling group {asg_name}")
        autoscaling_client = boto3.client('autoscaling')
        asg_arn = autoscaling_client.describe_auto_scaling_groups(
            query=f"AutoScalingGroups[?AutoScalingGroupName=='{asg_name}'].AutoScalingGroupARN"
        )['AutoScalingGroups'][0]['AutoScalingGroupARN']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um fornecedor de capacidade de nome {capacity_provider_name}")
        ecs_client.create_capacity_provider(
            name=capacity_provider_name,
            auto_scaling_group_provider={
                'autoScalingGroupArn': asg_arn,
                'managedScaling': {
                    'status': 'ENABLED',
                    'targetCapacity': 100
                },
                'managedTerminationProtection': 'DISABLED'
            }
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o fornecedor de capacidade de nome {capacity_provider_name}")
        capacity_provider = ecs_client.describe_capacity_providers(
            query=f"capacityProviders[?name=='{capacity_provider_name}'].name"
        )['capacityProviders'][0]['name']
        print(capacity_provider)
else:
    print("Código não executado")







#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("CAPACITY PROVIDER EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
capacity_provider_name = "capacityProviderTest1"
# cluster_name = "clusterEC2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o fornecedor de capacidade de nome {capacity_provider_name}")
    capacity_providers = ecs_client.describe_capacity_providers(
        query=f"capacityProviders[?name=='{capacity_provider_name}'].name"
    )['capacityProviders']
    if len(capacity_providers) > 1:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os fornecedores de capacidade existentes")
        all_capacity_providers = ecs_client.describe_capacity_providers(
            query="capacityProviders[].name[]"
        )['capacityProviders']
        print('\n'.join(all_capacity_providers))

        # Uncomment the following lines if you have a specific cluster to remove the capacity provider from
        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Removendo o fornecedor de capacidade de nome {capacity_provider_name} do cluster {cluster_name}")
        # ecs_client.put_cluster_capacity_providers(
        #     cluster=cluster_name,
        #     capacityProviders=[]
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o fornecedor de capacidade de nome {capacity_provider_name}")
        ecs_client.delete_capacity_provider(
            capacityProvider=capacity_provider_name,
            noCliPager=True
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os fornecedores de capacidade existentes")
        all_capacity_providers = ecs_client.describe_capacity_providers(
            query="capacityProviders[].name[]"
        )['capacityProviders']
        print('\n'.join(all_capacity_providers))
    else:
        print(f"Não existe o fornecedor de capacidade de nome {capacity_provider_name}")
else:
    print("Código não executado")