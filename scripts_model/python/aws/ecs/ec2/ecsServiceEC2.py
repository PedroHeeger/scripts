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
task_amount = 3
launch_type = "EC2"

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name} (Ignorando erro)...")
        erro = "ClientException"
        response = boto3.client('ecs').describe_services(cluster=cluster_name, services=[service_name])
        services = response.get('services', [])
        active_services = [s for s in services if s.get('status') == 'ACTIVE' and s.get('service_name') == service_name]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name}")
        if active_services:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o serviço de nome {service_name} no cluster {cluster_name}")
            print(active_services[0]['service_name'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os serviços ativos no cluster {cluster_name}")
            active_service_arns = [s['serviceArn'] for s in services if s.get('status') == 'ACTIVE']
               
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o serviço de nome {service_name} no cluster {cluster_name}")
            boto3.client('ecs').create_service(
                cluster=cluster_name,
                serviceName=service_name,
                taskDefinition=f"{task_name}:{task_version}",
                desiredCount=task_amount,
                launchType=launch_type,
                schedulingStrategy="REPLICA",
                deploymentConfiguration={'minimumHealthyPercent': 25, 'maximumPercent': 200}
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o serviço de nome {service_name} no cluster {cluster_name}")
            response = boto3.client('ecs').describe_services(cluster=cluster_name, services=[service_name])
            print(response['services'][0]['service_name'])
    except Exception as e:
        print(f"Erro: {e}")
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

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o cluster de nome {cluster_name}")
        response = boto3.client('ecs').describe_services(cluster=cluster_name, services=[service_name])
        services = response.get('services', [])
        
        if services:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs de todos os serviços criados no {cluster_name}")
            service_arns = [s['serviceArn'] for s in services]
            print("\n".join(service_arns))

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Atualizando a quantidade desejada de tarefas do serviço de nome {service_name} para 0")
            boto3.client('ecs').update_service(
                cluster=cluster_name,
                service=service_name,
                desiredCount=0
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o serviço de nome {service_name} do cluster {cluster_name}")
            boto3.client('ecs').delete_service(
                cluster=cluster_name,
                service=service_name
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs de todos os serviços criados no {cluster_name}")
            service_arns_after_deletion = boto3.client('ecs').list_services(cluster=cluster_name)['serviceArns']
            print("\n".join(service_arns_after_deletion))
        else:
            print(f"Não existe o cluster de nome {cluster_name}")
    except Exception as e:
        print(f"Erro: {e}")
else:
    print("Código não executado")