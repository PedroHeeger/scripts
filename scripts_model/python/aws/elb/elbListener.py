#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("LISTENER CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
albName = "albTest1"
tgName = "tgTest1"
listenerProtocol = "HTTP"
listenerPort = "80"

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do load balancer {albName}")
    lbArn = elbv2_client.describe_load_balancers(Names=[albName])['LoadBalancers'][0]['LoadBalancerArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tgName}")
    tgArn = elbv2_client.describe_target_groups(Names=[tgName])['TargetGroups'][0]['TargetGroupArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um listener vinculando o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
    listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
    matching_listeners = [listener for listener in listeners if listener['Port'] == int(listenerPort) and listener['Protocol'] == listenerProtocol and any(action['TargetGroupArn'] == tgArn for action in listener['DefaultActions'])]

    if matching_listeners:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe um listener vinculando o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
        print(matching_listeners[0]['ListenerArn'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os listeners do load balancer {albName}")
        all_listeners = [listener['ListenerArn'] for listener in listeners]
        print(all_listeners)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um listener para vincular o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
        elbv2_client.create_listener(
            LoadBalancerArn=lbArn,
            Protocol=listenerProtocol,
            Port=int(listenerPort),
            DefaultActions=[{'Type': 'forward', 'TargetGroupArn': tgArn}]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o listener que vincula o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
        new_listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
        new_matching_listener = [listener['ListenerArn'] for listener in new_listeners if listener['Port'] == int(listenerPort) and listener['Protocol'] == listenerProtocol and any(action['TargetGroupArn'] == tgArn for action in listener['DefaultActions'])]
        print(new_matching_listener[0])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("LISTENER EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
albName = "albTest1"
tgName = "tgTest1"
listenerProtocol = "HTTP"
listenerPort = "80"

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ELB")
    elbv2_client = boto3.client('elbv2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do load balancer {albName}")
    lbArn = elbv2_client.describe_load_balancers(Names=[albName])['LoadBalancers'][0]['LoadBalancerArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tgName}")
    tgArn = elbv2_client.describe_target_groups(Names=[tgName])['TargetGroups'][0]['TargetGroupArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um listener vinculando o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
    listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
    matching_listeners = [listener for listener in listeners if listener['Port'] == int(listenerPort) and listener['Protocol'] == listenerProtocol and any(action['TargetGroupArn'] == tgArn for action in listener['DefaultActions'])]

    if matching_listeners:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os listeners do load balancer {albName}")
        all_listeners = [listener['ListenerArn'] for listener in listeners]
        print(all_listeners)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do listener que vincula o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
        listenerArn = matching_listeners[0]['ListenerArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo listener que vincula o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
        elbv2_client.delete_listener(ListenerArn=listenerArn)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os listeners do load balancer {albName}")
        updated_listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
        updated_listener_arns = [listener['ListenerArn'] for listener in updated_listeners]
        print(updated_listener_arns)
    else:
        print(f"Não existe um listener que vincula o target group {tgName} ao load balancer {albName} na porta {listenerPort} do protocolo {listenerProtocol}")
else:
    print("Código não executado")