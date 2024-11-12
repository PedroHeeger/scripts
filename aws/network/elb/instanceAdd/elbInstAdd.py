#!/usr/bin/env python3

import boto3
from botocore.exceptions import ClientError
import time

print("***********************************************")
print("SERVIÇO: AWS EC2 E AWS ELB")
print("INSTANCE ADD TO ELB (CLB OR ALB)")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2ELBTest1"
# elb_name = "albTest1"
elb_name = "clbTest1"
tg_name = "tgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe uma instância ativa {tag_name_instance}")
    ec2 = boto3.client('ec2')
    instances = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:Name', 'Values': [tag_name_instance]},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )
    
    if len(instances['Reservations']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância {tag_name_instance}")
        instance_id = instances['Reservations'][0]['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Verificando o tipo de load balancer")
        elb = boto3.client('elb')
        elbv2 = boto3.client('elbv2')
        
        is_classic_lb = False
        is_application_lb = False
        try:
            classicLB = elb.describe_load_balancers(LoadBalancerNames=[elb_name])
            for lb in classicLB['LoadBalancerDescriptions']:
                if lb['LoadBalancerName'] == elb_name:
                    is_classic_lb = True
        except ClientError as e:
            pass

        try:
            applicationLB = elbv2.describe_load_balancers(Names=[elb_name])
            for lb in applicationLB['LoadBalancers']:
                if lb['LoadBalancerName'] == elb_name:
                    is_application_lb = True
        except ClientError as e:
            pass

        if is_classic_lb:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se a instância {tag_name_instance} está associada ao classic load balancer {elb_name}")
            lb_instances = elb.describe_load_balancers(LoadBalancerNames=[elb_name])
            condition = [i for i in lb_instances['LoadBalancerDescriptions'][0]['Instances'] if i['InstanceId'] == instance_id]
            
            if len(condition) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe a instância {tag_name_instance} associada ao classic load balancer {elb_name}")
                elbs = elb.describe_load_balancers(LoadBalancerNames=[elb_name])['LoadBalancerDescriptions']
                for lb in elbs:
                    for instance in lb.get('Instances', []):
                        if instance['InstanceId'] == instance_id:
                            print(f"Instância associada: {instance['InstanceId']}")
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todas as instâncias associadas ao classic load balancer {elb_name}")
                elbs = elb.describe_load_balancers()['LoadBalancerDescriptions']
                for lb in elbs:
                    for instance in lb.get('Instances', []):
                        print(f"Instância associada: {instance['InstanceId']}") 

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Registrando a instância {tag_name_instance} ao classic load balancer {elb_name}")
                elb.register_instances_with_load_balancer(
                    LoadBalancerName=elb_name,
                    Instances=[{'InstanceId': instance_id}]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando a instância {tag_name_instance} associada ao classic load balancer {elb_name}")
                elbs = elb.describe_load_balancers(LoadBalancerNames=[elb_name])['LoadBalancerDescriptions']
                for lb in elbs:
                    for instance in lb.get('Instances', []):
                        if instance['InstanceId'] == instance_id:
                            print(f"Instância associada: {instance['InstanceId']}")
        
        elif is_application_lb:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o target group {tg_name}")
            tg_exists = False
            tg_arn = ""
            tg_response = elbv2.describe_target_groups()
            for tg in tg_response['TargetGroups']:
                if tg['TargetGroupName'] == tg_name:
                    tg_exists = True
                    
            if tg_exists:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo a ARN do target group {tg_name}")
                tg_arn = tg['TargetGroupArn']
    
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe a instância {tag_name_instance} no target group {tg_name}")
                tg_health = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                condition = [
                    t['Target']['Id'] 
                    for t in tg_health['TargetHealthDescriptions'] 
                    if t['Target']['Id'] == instance_id and t['TargetHealth']['State'] != 'draining'
                ]
                if len(condition) > 0:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Já existe a instância {tag_name_instance} no target group {tg_name}")
                    response = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['Target']['Id'] == instance_id and target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando todas as instâncias no target group {tg_name}")
                    response = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Registrando a instância {tag_name_instance} no target group {tg_name}")
                    elbv2.register_targets(
                        TargetGroupArn=tg_arn,
                        Targets=[{'Id': instance_id}]
                    )
                    time.sleep(5)

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando a instância {tag_name_instance} no target group {tg_name}")
                    tg_health = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['Target']['Id'] == instance_id and target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")
            else:
                print(f"Não existe o target group {tg_name}. A instância {tag_name_instance} não pôde ser adicionada. Certifique-se de criar o target group")
        else:
            print(f"Não existe o load balancer {elb_name} ou não pertence aos tipos Classic ou Application. A instância {tag_name_instance} não foi vinculada ao load balancer")
    else:
        print(f"Não existe uma instância ativa {tag_name_instance}")
else:
    print("Código não executado")





#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError
import time

print("***********************************************")
print("SERVIÇO: AWS EC2 E AWS ELB")
print("INSTANCE REMOVE TO ELB (CLB OR ALB)")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2ELBTest1"
# elb_name = "albTest1"
elb_name = "clbTest1"
tg_name = "tgTest1"

resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe uma instância ativa {tag_name_instance}")
    ec2_client = boto3.client('ec2')
    
    response = ec2_client.describe_instances(
        Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}, {'Name': 'instance-state-name', 'Values': ['running']}]
    )
    instances = response['Reservations']
    
    if len(instances) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância {tag_name_instance}")
        instance_id = instances[0]['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Verificando o tipo de load balancer")
        elb_client = boto3.client('elb')
        elbv2_client = boto3.client('elbv2')
        is_classic_lb = False
        is_application_lb = False

        try:
            classicLB = elb_client.describe_load_balancers(LoadBalancerNames=[elb_name])
            for lb in classicLB['LoadBalancerDescriptions']:
                if lb['LoadBalancerName'] == elb_name:
                    is_classic_lb = True
        except ClientError as e:
            pass

        try:
            applicationLB = elbv2_client.describe_load_balancers(Names=[elb_name])
            for lb in applicationLB['LoadBalancers']:
                if lb['LoadBalancerName'] == elb_name:
                    is_application_lb = True
        except ClientError as e:
            pass

        if is_classic_lb:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se a instância {tag_name_instance} está associada ao classic load balancer {elb_name}")
            lb_instances = elb_client.describe_instance_health(LoadBalancerName=elb_name)
            condition = [i for i in lb_instances['InstanceStates'] if i['InstanceId'] == instance_id]

            if condition:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todas as instâncias associadas ao classic load balancer {elb_name}")
                for instance in lb_instances['InstanceStates']:
                    print(instance['InstanceId'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo a instância {tag_name_instance} associada ao classic load balancer {elb_name}")
                elb_client.deregister_instances_from_load_balancer(
                    LoadBalancerName=elb_name,
                    Instances=[{'InstanceId': instance_id}]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todas as instâncias associadas ao classic load balancer {elb_name}")
                lb_instances = elb_client.describe_instance_health(LoadBalancerName=elb_name)
                for instance in lb_instances['InstanceStates']:
                    print(instance['InstanceId'])
            else:
                print(f"Não existe a instância {tag_name_instance} associada ao classic load balancer {elb_name}")

        elif is_application_lb:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o target group {tg_name}")
            tg_response = elbv2_client.describe_target_groups()
            tg_condition = [tg for tg in tg_response['TargetGroups'] if tg['TargetGroupName'] == tg_name]
            
            if tg_condition:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo a ARN do target group {tg_name}")
                tg_arn = tg_condition[0]['TargetGroupArn']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe a instância {tag_name_instance} no target group {tg_name}")
                target_health = elbv2_client.describe_target_health(TargetGroupArn=tg_arn)
                target_condition = [
                    t['Target']['Id'] 
                    for t in target_health['TargetHealthDescriptions'] 
                    if t['Target']['Id'] == instance_id and t['TargetHealth']['State'] != 'draining'
                ]
                
                if target_condition:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando todas as instâncias no target group {tg_name}")
                    response = elbv2_client.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Removendo a instância {tag_name_instance} no target group {tg_name}")
                    elbv2_client.deregister_targets(
                        TargetGroupArn=tg_arn,
                        Targets=[{'Id': instance_id}]
                    )
                    time.sleep(5)

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando todas as instâncias no target group {tg_name}")
                    response = elbv2_client.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")
                else:
                    print(f"Não existe a instância {tag_name_instance} no target group {tg_name}")
            else:
                print(f"Não existe o target group {tg_name}.")

        else:
            print(f"Não existe o load balancer {elb_name} ou não pertence aos tipos Classic ou Application")
    else:
        print(f"Não existe uma instância ativa {tag_name_instance}")
else:
    print("Código não executado")