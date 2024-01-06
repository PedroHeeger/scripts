#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("TASK EXECUTION ON CLUSTER EC2")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
task_name = "taskEC2Test1"
revision = "7"
cluster_name = "clusterEC2Test1"
launch_type = "EC2"
region = "us-east-1"
aZ1 = "us-east-1a"
aZ2 = "us-east-1b"
account_id = "001727357081"
# task_arn = f"arn:aws:ecs:{region}:{account_id}:task/{cluster_name}"
# task_definition_arn = f"arn:aws:ecs:{region}:{account_id}:task-definition/{task_name}:{revision}"
task_definition_arn = f"arn:aws:ecs:{region}:{account_id}:task/{cluster_name}"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ").lower()
if response == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando clientes para o serviço ECS e EC2")
    ecs = boto3.client("ecs", region_name=region)
    ec2 = boto3.client("ec2", region_name=region)
    
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando uma função para executar a tarefa de nome {task_name} se ela não existir no cluster {cluster_name}")
    def executar_tarefa(task_name, revision, cluster_name, launch_type, aZ1, aZ2):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando as ARNs de todas as tarefas no cluster {cluster_name}")
        task_arns = ecs.list_tasks(cluster=cluster_name)["taskArns"]
        print(task_arns)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo os elementos de rede")
        vpc_id = ec2.describe_vpcs(Filters=[{"Name": "isDefault", "Values": ["true"]}])["Vpcs"][0]["VpcId"]
        subnet_id1 = ec2.describe_subnets(
            Filters=[
                {"Name": "availability-zone", "Values": [aZ1]},
                {"Name": "vpc-id", "Values": [vpc_id]},
            ]
        )["Subnets"][0]["SubnetId"]
        subnet_id2 = ec2.describe_subnets(
            Filters=[
                {"Name": "availability-zone", "Values": [aZ2]},
                {"Name": "vpc-id", "Values": [vpc_id]},
            ]
        )["Subnets"][0]["SubnetId"]
        sg_id = ec2.describe_security_groups(
            Filters=[{"Name": "vpc-id", "Values": [vpc_id]}, {"Name": "group-name", "Values": ["default"]}]
        )["SecurityGroups"][0]["GroupId"]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Executando a tarefa de nome {task_name} no cluster {cluster_name}")
        response = ecs.run_task(
            taskDefinition=f"{task_name}:{revision}",
            cluster=cluster_name,
            launchType=launch_type
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o Id da tarefa de nome {task_name} no cluster {cluster_name}")
        task_id = response["tasks"][0]["taskArn"].split("/")[-1]
        print(task_id)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a tarefa de nome {task_name} no cluster {cluster_name}")
    running_tasks = ecs.list_tasks(cluster=cluster_name, family=task_name, desiredStatus="RUNNING")["taskArns"]
    if len(running_tasks) > 1:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando uma lista de ARNs das revisões da tarefa de nome {task_name} do cluster {cluster_name}")
        task_arns_string = "\n".join(running_tasks)
        task_arns_list = task_arns_string.split()
        print(task_arns_list)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a tarefa de nome {task_name} no cluster {cluster_name} na revisão {revision}")
        for task_arn in task_arns_list:
            task_definition_arn_response = ecs.describe_tasks(
                cluster=cluster_name, tasks=[task_arn], query="tasks[].taskDefinitionArn"
            )["tasks"][0]["taskDefinitionArn"]
            if task_definition_arn_response == task_definition_arn:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe a tarefa de nome {task_name} no cluster {cluster_name} na revisão {revision}")
                print(task_definition_arn_response)
            else:
                executar_tarefa(task_name, revision, cluster_name, launch_type, aZ1, aZ2)
    else:
        executar_tarefa(task_name, revision, cluster_name, launch_type, aZ1, aZ2)
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("TASK EXCLUSION ON CLUSTER EC2")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
task_name = "taskEC2Test1"
cluster_name = "clusterEC2Test1"
revision = "7"
region = "us-east-1"
account_id = "001727357081"
task_definition_arn = f"arn:aws:ecs:{region}:{account_id}:task-definition/{task_name}:{revision}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a tarefa de nome {task_name} no cluster {cluster_name}")
    task_arns = boto3.client('ecs').list_tasks(
        cluster=cluster_name,
        family=task_name,
        desiredStatus="RUNNING"
    )['taskArns']

    if len(task_arns) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando uma lista de ARNs das revisões da tarefa de nome {task_name} no cluster {cluster_name}")
        print(task_arns)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a tarefa de nome {task_name} no cluster {cluster_name} na revisão {revision}")
        for task_arn in task_arns:
            if boto3.client('ecs').describe_tasks(
                    cluster=cluster_name,
                    tasks=[task_arn]
            )['tasks'][0]['taskDefinitionArn'] == task_definition_arn:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando as ARNs de todas as tarefas no cluster {cluster_name}")
                print(boto3.client('ecs').list_tasks(cluster=cluster_name)['taskArns'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Interrompendo a tarefa de nome {task_name} no cluster {cluster_name} na revisão {revision}")
                boto3.client('ecs').stop_task(
                    cluster=cluster_name,
                    task=task_arn
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando as ARNs de todas as tarefas no cluster {cluster_name}")
                print(boto3.client('ecs').list_tasks(cluster=cluster_name)['taskArns'])
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Não existe a tarefa {task_name} no cluster {cluster_name} na revisão {revision}")
                print(boto3.client('ecs').describe_tasks(
                    cluster=cluster_name,
                    tasks=[task_arn]
                )['tasks'][0]['taskDefinitionArn'])
    else:
        print(f"Não existe a tarefa {task_name} no cluster {cluster_name}")
else:
    print("Código não executado")