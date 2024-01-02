#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("TARGET GROUP ADD INSTANCE EC2")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tg_name = "tgTest1"
tag_name_instance = "ec2Test1"
# tag_name_instance = "ec2Test2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tg_name}")
    response = elbv2_client.describe_target_groups(
        Names=[tg_name]
    )

    if len(response['TargetGroups']) > 0:
        tg_arn = response['TargetGroups'][0]['TargetGroupArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância {tag_name_instance}")
        ec2_client = boto3.client('ec2')
        response = ec2_client.describe_instances(
            Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]
        )
        instance_id = response['Reservations'][0]['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a instância {tag_name_instance} no target group {tg_name}")
        response = elbv2_client.describe_target_health(
            TargetGroupArn=tg_arn
        )

        if any(instance['Target']['Id'] == instance_id for instance in response['TargetHealthDescriptions']):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe a instância {tag_name_instance} no target group {tg_name}")
            print([instance['Target']['Id'] for instance in response['TargetHealthDescriptions']])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as instâncias no target group {tg_name}")
            print(response['TargetHealthDescriptions'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Registrando a instância {tag_name_instance} no target group {tg_name}")
            elbv2_client.register_targets(
                TargetGroupArn=tg_arn,
                Targets=[{'Id': instance_id}]
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a instância {tag_name_instance} no target group {tg_name}")
            response = elbv2_client.describe_target_health(
                TargetGroupArn=tg_arn
            )
            print([instance['Target']['Id'] for instance in response['TargetHealthDescriptions']])
    else:
        print(f"Não existe o target group de nome {tg_name}")
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("TARGET GROUP REMOVE INSTANCE EC2")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tg_name = "tgTest1"
tag_name_instance = "ec2Test1"
# tag_name_instance = "ec2Test2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tg_name}")
    response = elbv2_client.describe_target_groups(
        Names=[tg_name]
    )

    if len(response['TargetGroups']) > 0:
        tg_arn = response['TargetGroups'][0]['TargetGroupArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cliente para o serviço EC2")
        ec2_client = boto3.client('ec2')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância {tag_name_instance}")
        response = ec2_client.describe_instances(
            Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]
        )

        if 'Reservations' in response and len(response['Reservations']) > 0 and 'Instances' in response['Reservations'][0] and len(response['Reservations'][0]['Instances']) > 0:
            instance_id = response['Reservations'][0]['Instances'][0]['InstanceId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe a instância {tag_name_instance} no target group {tg_name}")
            response = elbv2_client.describe_target_health(
                TargetGroupArn=tg_arn
            )

            if any(instance['Target']['Id'] == instance_id for instance in response['TargetHealthDescriptions']):
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todas as instâncias no target group {tg_name}")
                print([instance['Target']['Id'] for instance in response['TargetHealthDescriptions']])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo a instância {tag_name_instance} no target group {tg_name}")
                elbv2_client.deregister_targets(
                    TargetGroupArn=tg_arn,
                    Targets=[{'Id': instance_id}]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todas as instâncias no target group {tg_name}")
                response = elbv2_client.describe_target_health(
                    TargetGroupArn=tg_arn
                )
                print([instance['Target']['Id'] for instance in response['TargetHealthDescriptions']])
            else:
                print(f"Não existe a instância {tag_name_instance} no target group {tg_name}")
        else:
            print(f"Não foi encontrada a instância {tag_name_instance}")
    else:
        print(f"Não existe o target group de nome {tg_name}")
else:
    print("Código não executado")