#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("SERVICE FARGATE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
service_name = "svcFargateTest1"
cluster_name = "clusterFargateTest1"
task_name = "taskFargateTest1"
task_version = "11"
task_amount = 2
launch_type = "FARGATE"
aZ1 = "us-east-1a"
aZ2 = "us-east-1b"
tg_name = "tgTest1"
container_name1 = "containerTest1"
container_port1 = 8080

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name} (Ignorando erro)...")
        erro = "ClientException"
        response = boto3.client('ecs').describe_services(cluster=cluster_name, services=[service_name])
        services = response.get('services', [])
        active_services = [s for s in services if s.get('status') == 'ACTIVE' and s.get('serviceName') == service_name]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o serviço de nome {service_name} no cluster {cluster_name}")
        if active_services:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o serviço de nome {service_name} no cluster {cluster_name}")
            print(active_services[0]['serviceName'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os serviços ativos no cluster {cluster_name}")
            active_service_arns = [s['serviceArn'] for s in services if s.get('status') == 'ACTIVE']
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo os elementos de rede")
            vpcId = boto3.client('ec2').describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])['Vpcs'][0]['VpcId']
            subnetId1 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ1]}, {'Name': 'vpc-id', 'Values': [vpcId]}])['Subnets'][0]['SubnetId']
            subnetId2 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ2]}, {'Name': 'vpc-id', 'Values': [vpcId]}])['Subnets'][0]['SubnetId']
            sgId = boto3.client('ec2').describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpcId]}, {'Name': 'group-name', 'Values': ['default']}])['SecurityGroups'][0]['GroupId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo a ARN do target group {tg_name}")
            tg_arn = boto3.client('elbv2').describe_target_groups(Names=[tg_name])['TargetGroups'][0]['TargetGroupArn']
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o serviço de nome {service_name} no cluster {cluster_name}")
            boto3.client('ecs').create_service(
                cluster=cluster_name,
                serviceName=service_name,
                taskDefinition=f"{task_name}:{task_version}",
                desiredCount=task_amount,
                launchType=launch_type,
                platformVersion="LATEST",
                schedulingStrategy="REPLICA",
                deploymentConfiguration={'minimumHealthyPercent': 25, 'maximumPercent': 200},
                networkConfiguration={'awsvpcConfiguration': {'subnets': [subnetId1, subnetId2], 'securityGroups': [sgId], 'assignPublicIp': 'ENABLED'}}
            )

            # print("-----//-----//-----//-----//-----//-----//-----")
            # print(f"Criando o serviço de nome {service_name} no cluster {cluster_name} com load balancer")
            # boto3.client('ecs').create_service(
            #     cluster=cluster_name,
            #     serviceName=service_name,
            #     taskDefinition=f"{task_name}:{task_version}",
            #     desiredCount=task_amount,
            #     launchType=launch_type,
            #     platformVersion="LATEST",
            #     schedulingStrategy="REPLICA",
            #     deploymentConfiguration={'minimumHealthyPercent': 25, 'maximumPercent': 200},
            #     networkConfiguration={'awsvpcConfiguration': {'subnets': [subnetId1, subnetId2], 'securityGroups': [sgId], 'assignPublicIp': 'ENABLED'}},
            #     loadBalancers=[{'targetGroupArn': tg_arn, 'containerName': container_name1, 'containerPort': container_port1}]
            # )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o serviço de nome {service_name} no cluster {cluster_name}")
            response = boto3.client('ecs').describe_services(cluster=cluster_name, services=[service_name])
            print(response['services'][0]['serviceName'])
    except Exception as e:
        print(f"Erro: {e}")
else:
    print("Código não executado")


#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("SERVICE FARGATE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
service_name = "svcFargateTest1"
cluster_name = "clusterFargateTest1"

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