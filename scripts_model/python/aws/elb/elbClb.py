#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("CLASSIC LOAD BALANCER (CLB) CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
clb_name = "clbTest1"
listener_protocol = "HTTP"
listener_port = 80
instance_protocol = "HTTP"
instance_port = 80
aZ1 = "us-east-1a"
aZ2 = "us-east-1b"
sg_name = "default"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2 e outro para o ELB")
    elb_client = boto3.client('elb')
    ec2_client = boto3.client('ec2')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o classic load balancer de nome {clb_name}")
        elbs = elb_client.describe_load_balancers(LoadBalancerNames=[clb_name])['LoadBalancerDescriptions']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o classic load balancer de nome {clb_name}")
        print(elbs[0]['LoadBalancerName'])

    except Exception as e:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os classic load balancers criados")
        elbs = elb_client.describe_load_balancers()['LoadBalancerDescriptions']
        for elb in elbs:
            print(elb['LoadBalancerName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o ID do grupo de segurança")
        vpc_id = ec2_client.describe_vpcs()['Vpcs'][0]['VpcId']
        sg_id = ec2_client.describe_security_groups(
            Filters=[
                {'Name': 'vpc-id', 'Values': [vpc_id]},
                {'Name': 'group-name', 'Values': [sg_name]}
            ]
        )['SecurityGroups'][0]['GroupId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o classic load balancer de nome {clb_name}")
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
            AvailabilityZones=[aZ1, aZ2],
            SecurityGroups=[sg_id]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a verificação de integridade do classic load balancer de nome {clb_name}")
        elb_client.configure_health_check(
            LoadBalancerName=clb_name,
            HealthCheck={
                'Target': f'{listener_protocol}:{listener_port}/index.html',
                'Interval': 15,
                'UnhealthyThreshold': 2,
                'HealthyThreshold': 5,
                'Timeout': 5
            }
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o classic load balancer de nome {clb_name}")
        elbs = elb_client.describe_load_balancers(LoadBalancerNames=[clb_name])['LoadBalancerDescriptions']
        print(elbs[0]['LoadBalancerName'])
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("CLASSIC LOAD BALANCER (CLB) EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
clb_name = "clbTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elb_client = boto3.client('elb')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o classic load balancer de nome {clb_name}")
    elbs = elb_client.describe_load_balancers(LoadBalancerNames=[clb_name])['LoadBalancerDescriptions']

    if elbs:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todos os classic load balancers criados")
            all_elbs = elb_client.describe_load_balancers()['LoadBalancerDescriptions']
            for elb in all_elbs:
                print(elb['LoadBalancerName'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o classic load balancer de nome {clb_name}")
            elb_client.delete_load_balancer(LoadBalancerName=clb_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todos os classic load balancers criados")
            all_elbs = elb_client.describe_load_balancers()['LoadBalancerDescriptions']
            for elb in all_elbs:
                print(elb['LoadBalancerName'])
    else:
        print(f"Não existe o classic load balancer de nome {clb_name}")
else:
    print("Código não executado") 