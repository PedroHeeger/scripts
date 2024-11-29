#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ELB")
print("CLASSIC LOAD BALANCER (CLB) CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
clb_name = "clbTest1"
listener_protocol = "HTTP"
listener_port = 80
instance_protocol = "HTTP"
instance_port = 80
az1 = "us-east-1a"
az2 = "us-east-1b"
sg_name = "default"
hc_protocol = "HTTP"
hc_port = "80"
hc_path = "index.html"
hc_interval_seconds = 15
unhealthy_threshold = 2
healthy_threshold = 5
hc_timeout_seconds = 5

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o classic load balancer {clb_name}")
    elb_client = boto3.client('elb')

    try:
        response = elb_client.describe_load_balancers(LoadBalancerNames=[clb_name])['LoadBalancerDescriptions']
        lb_found = len(response) > 0 and 'LoadBalancerName' in response[0]
    except ClientError as e:
        lb_found = False

    if lb_found:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o classic load balancer {clb_name}")
        elbs = elb_client.describe_load_balancers(LoadBalancerNames=[clb_name])['LoadBalancerDescriptions']
        print(elbs[0]['LoadBalancerName'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os classic load balancers criados")
        elbs = elb_client.describe_load_balancers()['LoadBalancerDescriptions']
        for elb in elbs:
            print(elb['LoadBalancerName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o ID dos elementos de rede")
        ec2_client = boto3.client('ec2')
        vpc_id = ec2_client.describe_vpcs()['Vpcs'][0]['VpcId']
        sg_id = ec2_client.describe_security_groups(
            Filters=[
                {'Name': 'vpc-id', 'Values': [vpc_id]},
                {'Name': 'group-name', 'Values': [sg_name]}
            ]
        )['SecurityGroups'][0]['GroupId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o classic load balancer {clb_name}")
        elb_client.create_load_balancer(
            LoadBalancerName=clb_name,
            Listeners=[
                {
                    'Protocol': listener_protocol,
                    'LoadBalancerPort': listener_port,
                    'InstanceProtocol': instance_protocol,
                    'InstancePort': instance_port
                }
            ],
            AvailabilityZones=[az1, az2],
            SecurityGroups=[sg_id]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a verificação de integridade do classic load balancer {clb_name}")
        elb_client.configure_health_check(
            LoadBalancerName=clb_name,
            HealthCheck={
                'Target': f'{hc_protocol}:{hc_port}/{hc_path}',
                'Interval': hc_interval_seconds,
                'UnhealthyThreshold': unhealthy_threshold,
                'HealthyThreshold': healthy_threshold,
                'Timeout': hc_timeout_seconds
            }
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o classic load balancer {clb_name}")
        elbs = elb_client.describe_load_balancers(LoadBalancerNames=[clb_name])['LoadBalancerDescriptions']
        print(elbs[0]['LoadBalancerName'])
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ELB")
print("CLASSIC LOAD BALANCER (CLB) EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
clb_name = "clbTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o classic load balancer {clb_name}")
    elb_client = boto3.client('elb')

    try:
        response = elb_client.describe_load_balancers(LoadBalancerNames=[clb_name])['LoadBalancerDescriptions']
        lb_found = len(response) > 0 and 'LoadBalancerName' in response[0]
    except ClientError as e:
        lb_found = False

    if lb_found:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os classic load balancers criados")
        all_elbs = elb_client.describe_load_balancers()['LoadBalancerDescriptions']
        for elb in all_elbs:
            print(elb['LoadBalancerName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o classic load balancer {clb_name}")
        elb_client.delete_load_balancer(LoadBalancerName=clb_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os classic load balancers criados")
        all_elbs = elb_client.describe_load_balancers()['LoadBalancerDescriptions']
        for elb in all_elbs:
            print(elb['LoadBalancerName'])
    else:
        print(f"Não existe o classic load balancer {clb_name}")
else:
    print("Código não executado") 