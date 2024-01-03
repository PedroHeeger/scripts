#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("LISTENER CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
lb_name = "lbTest1"
tg_name = "tgTest1"
listener_protocol = "HTTP"
listener_port = 80

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do load balancer {lb_name}")
    lb_response = elbv2_client.describe_load_balancers(Names=[lb_name])
    lb_arn = lb_response['LoadBalancers'][0]['LoadBalancerArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tg_name}")
    tg_response = elbv2_client.describe_target_groups(Names=[tg_name])
    tg_arn = tg_response['TargetGroups'][0]['TargetGroupArn']

    condition = len(elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']) > 1 and \
                len(elbv2_client.describe_listeners(LoadBalancerArn=lb_arn, Query='Listeners[].DefaultActions[?TargetGroupArn==`{}`]'.format(tg_arn))['Listeners']) > 1

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um listener vinculando o target group {tg_name} ao load balancer {lb_name}")
    if condition:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe um listener vinculando o target group {tg_name} ao load balancer {lb_name}")
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']
        for listener in listeners:
            print(listener['ListenerArn'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os listeners do load balancer {lb_name}")
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']
        for listener in listeners:
            print(listener['ListenerArn'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um listener para vincular o target group {tg_name} ao load balancer {lb_name}")
        elbv2_client.create_listener(
            LoadBalancerArn=lb_arn,
            Protocol=listener_protocol,
            Port=listener_port,
            DefaultActions=[{'Type': 'forward', 'TargetGroupArn': tg_arn}]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o listener que vincula o target group {tg_name} ao load balancer {lb_name}")
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']
        for listener in listeners:
            print(listener['ListenerArn'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("LISTENER EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
lb_name = "lbTest1"
tg_name = "tgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do load balancer {lb_name}")
    lb_response = elbv2_client.describe_load_balancers(Names=[lb_name])
    lb_arn = lb_response['LoadBalancers'][0]['LoadBalancerArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tg_name}")
    tg_response = elbv2_client.describe_target_groups(Names=[tg_name])
    tg_arn = tg_response['TargetGroups'][0]['TargetGroupArn']

    listeners = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']
    condition = len(listeners) > 0 and any(listener['DefaultActions'][0]['TargetGroupArn'] == tg_arn for listener in listeners)

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um listener vinculando o target group {tg_name} ao load balancer {lb_name}")
    if condition:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os listeners do load balancer {lb_name}")
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']
        for listener in listeners:
            print(listener['ListenerArn'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do listener que vincula o target group {tg_name} ao load balancer {lb_name}")
        listener_arn = listeners[0]['ListenerArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo listener que vincula o target group {tg_name} ao load balancer {lb_name}")
        elbv2_client.delete_listener(ListenerArn=listener_arn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os listeners do load balancer {lb_name}")
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']
        for listener in listeners:
            print(listener['ListenerArn'])
    else:
        print(f"Não existe um listener que vincula o target group {tg_name} ao load balancer {lb_name}")
else:
    print("Código não executado")