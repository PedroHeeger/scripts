#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("SERVICE EC2 CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
service_name = "svcEC2Test1"
cluster_name = "clusterEC2Test1"
task_name = "taskEC2Test1"
task_version = "7"
task_amount = 2
launch_type = "EC2"
tg_name = "tgTest1"
container_name1 = "containerTest1"
container_port1 = 8080

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name} (Ignorando erro)...")
    try:
        response = ecs_client.describe_services(cluster=cluster_name, services=[service_name])
        condition = response['services'][0]['status']
    except ecs_client.exceptions.ServiceNotFoundException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name}")
    excluded_status = ["ACTIVE", 0]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o serviço de nome {service_name} no cluster {cluster_name}")
        print(response['services'][0]['serviceName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os serviços no cluster {cluster_name}")
        services = ecs_client.list_services(cluster=cluster_name)['serviceArns']
        print(services)

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Extraindo o ARN do target group {tg_name}")
        # tg_arn = boto3.client('elbv2').describe_target_groups(
        #     query=f"TargetGroups[?TargetGroupName=='{tg_name}'].TargetGroupArn",
        #     output='text'
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o serviço de nome {service_name} no cluster {cluster_name}")
        ecs_client.create_service(
            cluster=cluster_name,
            serviceName=service_name,
            taskDefinition=f"{task_name}:{task_version}",
            desiredCount=task_amount,
            launchType=launch_type,
            schedulingStrategy="REPLICA",
            deploymentConfiguration={
                "minimumHealthyPercent": 25,
                "maximumPercent": 200
            }
        )

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando o serviço de nome {service_name} no cluster {cluster_name}")
        # ecs_client.create_service(
        #     cluster=cluster_name,
        #     serviceName=service_name,
        #     taskDefinition=f"{task_name}:{task_version}",
        #     desiredCount=task_amount,
        #     launchType=launch_type,
        #     schedulingStrategy="REPLICA",
        #     deploymentConfiguration={'minimumHealthyPercent': 25, 'maximumPercent': 200},
        #     loadBalancers=[
        #         {
        #             'targetGroupArn': tg_arn,
        #             'containerName': container_name1,
        #             'containerPort': container_port1
        #         }
        #     ],
        #     placementConstraints=[{'type': 'distinctInstance'}]
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o serviço de nome {service_name} no cluster {cluster_name}")
        response = boto3.client('ecs').describe_services(cluster=cluster_name, services=[service_name])
        print(response['services'][0]['service_name'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("SERVICE EC2 EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
service_name = "svcEC2Test1"
cluster_name = "clusterEC2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name} (Ignorando erro)...")
    try:
        response = ecs_client.describe_services(cluster=cluster_name, services=[service_name])
        condition = response['services'][0]['status']
    except ecs_client.exceptions.InvalidParameterException:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name}")
    excluded_status = ["ACTIVE", 0]
    if condition in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs de todos os serviços criados no {cluster_name}")
        services = ecs_client.list_services(cluster=cluster_name)['serviceArns']
        print(services)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Atualizando a quantidade desejada de tarefas do serviço de nome {service_name} para 0")
        ecs_client.update_service(cluster=cluster_name, service=service_name, desiredCount=0, forceNewDeployment=True)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o serviço de nome {service_name} do cluster {cluster_name}")
        ecs_client.delete_service(cluster=cluster_name, service=service_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs de todos os serviços criados no {cluster_name}")
        service_arns_after_deletion = boto3.client('ecs').list_services(cluster=cluster_name)['serviceArns']
        print("\n".join(service_arns_after_deletion))
    else:
        print(f"Não existe o cluster de nome {cluster_name}")
else:
    print("Código não executado")