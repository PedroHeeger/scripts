#!/usr/bin/env python

import boto3
# import json

print("-----//-----//-----//-----//-----//-----//-----")
print("SERVIÇO: AWS ECS")
print("TASK FARGATE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
task_name = "taskFargateTest1"
execution_role_name = "ecsTaskExecutionRole"
revision = "11"
launch_type = "FARGATE"
container_name1 = "containerTest1"
container_name2 = "containerTest2"
docker_image1 = "docker.io/fabricioveronez/conversao-temperatura:latest"
docker_image2 = "docker.io/library/httpd:latest"
log_group_name = "/aws/ecs/fargate/taskFargateTest1"
region = "us-east-1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("Verificando se a definição de tarefa está vazia (Ignorando erro)...")
    erro = "ClientException"
    try:
        response = boto3.client('ecs').describe_task_definition(taskDefinition=task_name)
        condition = response['taskDefinition']['revision']
    except boto3.exceptions.botocore.exceptions.ClientError as e:
        if erro in str(e):
            print("A definição de tarefa está vazia")
            condition = 0
        else:
            raise

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a definição de tarefa de nome {task_name} na revisão {revision}")
    if condition == int(revision):
        print(f"-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a definição de tarefa de nome {task_name} na revisão {revision}")
        response = boto3.client('ecs').describe_task_definition(taskDefinition=task_name)
        print(response['taskDefinition']['family'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando as ARNs de todas as definições de tarefas criadas")
        task_definition_arns = boto3.client('ecs').list_task_definitions()
        print("\n".join(task_definition_arns['taskDefinitionArns']))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da role {execution_role_name}")
        iam_client = boto3.client('iam')
        execution_role_arn = iam_client.get_role(
            RoleName=execution_role_name)['Role']['Arn']
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Registrando uma definição de tarefa de nome {task_name} na revisão {revision}")
        ecs_client = boto3.client('ecs')
        container_definitions = [
            {
                "name": container_name1,
                "image": docker_image1,
                "cpu": 128,
                "memory": 256,
                "portMappings": [
                    {
                        "containerPort": 8080,
                        "hostPort": 8080
                    }
                ],
                "essential": False,
                "logConfiguration": {
                    "logDriver": "awslogs",
                    "options": {
                        "awslogs-group": log_group_name,
                        "awslogs-region": region,
                        "awslogs-stream-prefix": container_name1
                    }
                }
            },
            {
                "name": container_name2,
                "image": docker_image2,
                "cpu": 128,
                "memory": 256,
                "portMappings": [
                    {
                        "containerPort": 80,
                        "hostPort": 80
                    }
                ],
                "logConfiguration": {
                    "logDriver": "awslogs",
                    "options": {
                        "awslogs-group": log_group_name,
                        "awslogs-region": region,
                        "awslogs-stream-prefix": container_name2
                    }
                }
            }
        ]
        
        ecs_client.register_task_definition(
            family=task_name,
            networkMode="awsvpc",
            requiresCompatibilities=[launch_type],
            executionRoleArn=execution_role_arn,
            cpu="256",
            memory="512",
            runtimePlatform={"cpuArchitecture": "X86_64", "operatingSystemFamily": "LINUX"},
            containerDefinitions=container_definitions
        )
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a definição de tarefa de nome {task_name}")
        response = boto3.client('ecs').describe_task_definition(taskDefinition=task_name)
        print(response['taskDefinition']['family'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("TASK FARGATE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
task_name = "taskFargateTest1"
revision = "11"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("Verificando se a definição de tarefa está vazia (Ignorando erro)...")
    erro = "ClientException"
    try:
        response = boto3.client('ecs').describe_task_definition(
            taskDefinition=f"{task_name}:{revision}"
        )
        print("A definição de tarefa não está vazia")
        condition = response['taskDefinition']['revision']
    except boto3.exceptions.Boto3Error as e:
        if erro in str(e):
            print("A definição de tarefa está vazia")
            condition = 0
        else:
            raise

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a definição de tarefa de nome {task_name} na revisão {revision}")
    if condition == int(revision):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs de todas as definições de tarefas criadas ativas")
        ecs_client = boto3.client('ecs')
        response_active = ecs_client.list_task_definitions(status='ACTIVE', maxResults=100)
        print("Task Definition ARNs (Ativas):")
        for task_definition_arn in response_active['taskDefinitionArns']:
            print(task_definition_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs de todas as definições de tarefas criadas inativas")
        ecs_client = boto3.client('ecs')
        response_inactive = ecs_client.list_task_definitions(status='INACTIVE', maxResults=100)
        print("Task Definition ARNs (Inativas):")
        for task_definition_arn in response_inactive['taskDefinitionArns']:
            print(task_definition_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o registro da definição de tarefa de nome {task_name} na revisão {revision}")
        boto3.client('ecs').deregister_task_definition(
            taskDefinition=f"{task_name}:{revision}"
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a definição de tarefa de nome {task_name} na revisão {revision}")
        boto3.client('ecs').delete_task_definition(
            taskDefinition=f"{task_name}:{revision}"
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs de todas as definições de tarefas criadas ativas")
        ecs_client = boto3.client('ecs')
        response_active = ecs_client.list_task_definitions(status='ACTIVE', maxResults=100)
        print("Task Definition ARNs (Ativas):")
        for task_definition_arn in response_active['taskDefinitionArns']:
            print(task_definition_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs de todas as definições de tarefas criadas inativas")
        ecs_client = boto3.client('ecs')
        response_inactive = ecs_client.list_task_definitions(status='INACTIVE', maxResults=100)
        print("Task Definition ARNs (Inativas):")
        for task_definition_arn in response_inactive['taskDefinitionArns']:
            print(task_definition_arn)
    else:
        print(f"Não existe a definição de tarefa de nome {task_name} na revisão {revision}")
else:
    print("Código não executado")