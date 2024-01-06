#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECS")
print("SERVICE EC2 CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
serviceName = "svcEC2Test1"
clusterName = "clusterEC2Test1"
taskName = "taskEC2Test1"
taskVersion = "7"
taskAmount = 3
launchType = "EC2"
# aZ1 = "us-east-1a"
# aZ2 = "us-east-1b"

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o serviço de nome {serviceName} no cluster {clusterName} (Ignorando erro)...")
        erro = "ClientException"
        response = boto3.client('ecs').describe_services(cluster=clusterName, services=[serviceName])
        services = response.get('services', [])
        active_services = [s for s in services if s.get('status') == 'ACTIVE' and s.get('serviceName') == serviceName]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o serviço de nome {serviceName} no cluster {clusterName}")
        if active_services:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o serviço de nome {serviceName} no cluster {clusterName}")
            print(active_services[0]['serviceName'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os serviços ativos no cluster {clusterName}")
            active_service_arns = [s['serviceArn'] for s in services if s.get('status') == 'ACTIVE']
        
            # print("-----//-----//-----//-----//-----//-----//-----")
            # print("Extraindo os elementos de rede")
            # vpcId = boto3.client('ec2').describe_vpcs(Filters=[{'Name': 'isDefault', 'Values': ['true']}])['Vpcs'][0]['VpcId']
            # subnetId1 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ1]}, {'Name': 'vpc-id', 'Values': [vpcId]}])['Subnets'][0]['SubnetId']
            # subnetId2 = boto3.client('ec2').describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [aZ2]}, {'Name': 'vpc-id', 'Values': [vpcId]}])['Subnets'][0]['SubnetId']
            # sgId = boto3.client('ec2').describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpcId]}, {'Name': 'group-name', 'Values': ['default']}])['SecurityGroups'][0]['GroupId']
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o serviço de nome {serviceName} no cluster {clusterName}")
            boto3.client('ecs').create_service(
                cluster=clusterName,
                serviceName=serviceName,
                taskDefinition=f"{taskName}:{taskVersion}",
                desiredCount=taskAmount,
                launchType=launchType,
                schedulingStrategy="REPLICA",
                deploymentConfiguration={'minimumHealthyPercent': 25, 'maximumPercent': 200}
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o serviço de nome {serviceName} no cluster {clusterName}")
            response = boto3.client('ecs').describe_services(cluster=clusterName, services=[serviceName])
            print(response['services'][0]['serviceName'])
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
serviceName = "svcEC2Test1"
clusterName = "clusterEC2Test1"

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o cluster de nome {clusterName}")
        response = boto3.client('ecs').describe_services(cluster=clusterName, services=[serviceName])
        services = response.get('services', [])
        
        if services:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs de todos os serviços criados no {clusterName}")
            service_arns = [s['serviceArn'] for s in services]
            print("\n".join(service_arns))

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Atualizando a quantidade desejada de tarefas do serviço de nome {serviceName} para 0")
            boto3.client('ecs').update_service(
                cluster=clusterName,
                service=serviceName,
                desiredCount=0
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o serviço de nome {serviceName} do cluster {clusterName}")
            boto3.client('ecs').delete_service(
                cluster=clusterName,
                service=serviceName
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando as ARNs de todos os serviços criados no {clusterName}")
            service_arns_after_deletion = boto3.client('ecs').list_services(cluster=clusterName)['serviceArns']
            print("\n".join(service_arns_after_deletion))
        else:
            print(f"Não existe o cluster de nome {clusterName}")
    except Exception as e:
        print(f"Erro: {e}")
else:
    print("Código não executado")