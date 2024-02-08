#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("TASK EC2 CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
task_name = "taskEC2Test1"
execution_role_name = "ecsTaskExecutionRole"
launch_type = "EC2"
container_name1 = "containerTest1"
container_name2 = "containerTest2"
docker_image1 = "docker.io/fabricioveronez/conversao-temperatura:latest"
docker_image2 = "public.ecr.aws/nginx/nginx"
# docker_image2 = "docker.io/library/httpd:latest"
log_group_name = "/aws/ecs/ec2/taskEc2Test1"
region = "us-east-1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS e IAM")
    ecs_client = boto3.client('ecs', region_name=region)
    iam_client = boto3.client('iam', region_name=region)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando uma função para executar a definição de tarefa de nome {task_name} na versão correspondente")
    def executar_tarefa(execution_role_name, task_name, launch_type, container_name1, docker_image1, log_group_name, region, container_name2, docker_image2):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs das revisões da definição de tarefa ativas de nome {task_name}")
        task_definitions = ecs_client.list_task_definitions(familyPrefix=task_name)['taskDefinitionArns']
        print(task_definitions)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN da role {execution_role_name}")
        execution_role_arn = iam_client.get_role(RoleName=execution_role_name)['Role']['Arn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Registrando uma definição de tarefa de nome {task_name}")
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
        response = ecs_client.register_task_definition(
            family=task_name,
            networkMode="bridge",
            requiresCompatibilities=[launch_type],
            executionRoleArn=execution_role_arn,
            cpu="256",
            memory="512",
            runtimePlatform={"cpuArchitecture": "X86_64", "operatingSystemFamily": "LINUX"},
            containerDefinitions=container_definitions
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a definição de tarefa de nome {task_name}")
        task_definition = response['taskDefinition']['family']
        print(task_definition)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a revisão da definição de tarefa de nome {task_name}")
        revision = response['taskDefinition']['revision']
        print(revision)


    try:
        response = ecs_client.describe_task_definition(taskDefinition=task_name)
        revision = response['taskDefinition']['revision']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe uma definição de tarefa de nome {task_name}")
        print(f"{task_name}:{revision}")

        print("-----//-----//-----//-----//-----//-----//-----")
        new_revision = int(revision) + 1
        resposta = input(f"Quer implementar a versão {new_revision}? (y/n) ")
        if resposta.lower() == 'y':
            executar_tarefa(execution_role_name, task_name, launch_type, container_name1, docker_image1, log_group_name, region, container_name2, docker_image2)
    except Exception as e:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Criando a definição de tarefa")
        executar_tarefa(execution_role_name, task_name, launch_type, container_name1, docker_image1, log_group_name, region, container_name2, docker_image2)
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("TASK EC2 EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
task_name = "taskEC2Test1"
revision = "14"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECS")
    ecs_client = boto3.client('ecs')

    try:
        response = ecs_client.describe_task_definition(taskDefinition=f"{task_name}:{revision}")
        status = response['taskDefinition']['status']

        if status == "ACTIVE":
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs das revisões da definição de tarefa ativas de nome {task_name}")
            task_definitions_active = ecs_client.list_task_definitions(familyPrefix=task_name)['taskDefinitionArns']
            print(task_definitions_active)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs das revisões da definição de tarefa inativas de nome {task_name}")
            task_definitions_inactive = ecs_client.list_task_definitions(familyPrefix=task_name, status='INACTIVE')['taskDefinitionArns']
            print(task_definitions_inactive)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o registro da definição de tarefa de nome {task_name} na revisão {revision}")
            ecs_client.deregister_task_definition(taskDefinition=f"{task_name}:{revision}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a definição de tarefa de nome {task_name} na revisão {revision}")
            ecs_client.delete_task_definitions(taskDefinitions=[f"{task_name}:{revision}",])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs das revisões da definição de tarefa ativas de nome {task_name}")
            task_definitions_active_after_deletion = ecs_client.list_task_definitions(familyPrefix=task_name)['taskDefinitionArns']
            print(task_definitions_active_after_deletion)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs das revisões da definição de tarefa inativas de nome {task_name}")
            task_definitions_inactive_after_deletion = ecs_client.list_task_definitions(familyPrefix=task_name, status='INACTIVE')['taskDefinitionArns']
            print(task_definitions_inactive_after_deletion)

        else:
            print(f"Não existe a definição de tarefa de nome {task_name} na revisão {revision}")
    except ecs_client.exceptions.ClientException:
        print(f"Não existe a definição de tarefa de nome {task_name} na revisão {revision}")
else:
    print("Código não executado")