#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("LISTENER RULE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"
tg_name = "tgTest1"
listener_protocol = "HTTP"
listener_port = "80"
redirect_protocol = "HTTPS"
redirect_port = 443
listener_rule_name = "listenerRuleTest1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n): ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do load balancer {alb_name}")
    elbv2_client = boto3.client('elbv2')
    lb_response = elbv2_client.describe_load_balancers(Names=[alb_name])
    lb_arn = lb_response['LoadBalancers'][0]['LoadBalancerArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tg_name}")
    tg_response = elbv2_client.describe_target_groups(Names=[tg_name])
    tg_arn = tg_response['TargetGroups'][0]['TargetGroupArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um listener vinculando o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
    listeners_response = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)
    if any(listener['Port'] == int(listener_port) and listener['Protocol'] == listener_protocol and any(action['TargetGroupArn'] == tg_arn for action in listener.get('DefaultActions', [])) for listener in listeners_response['Listeners']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do listener cujo protocolo é {listener_protocol} e a porta é {listener_port}")
        listener_arn = next((listener['ListenerArn'] for listener in listeners_response['Listeners'] if listener['Port'] == int(listener_port) and listener['Protocol'] == listener_protocol and any(action['TargetGroupArn'] == tg_arn for action in listener.get('DefaultActions', []))), None)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe uma regra no listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
        rules_response = elbv2_client.describe_rules(ListenerArn=listener_arn)
        if any(action['Type'] == 'redirect' and action['RedirectConfig']['Protocol'] == redirect_protocol for rule in rules_response['Rules'] for action in rule.get('Actions', [])):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe uma regra no listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
            print("\n".join(rule['RuleArn'] for rule in rules_response['Rules'] if any(action['Type'] == 'redirect' and action['RedirectConfig']['Protocol'] == redirect_protocol for action in rule.get('Actions', []))))
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as regras do listener de protocolo {listener_protocol} e porta {listener_port}")
            print("\n".join(rule['RuleArn'] for rule in rules_response['Rules']))

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando uma regra no listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
            elbv2_client.create_rule(
                ListenerArn=listener_arn,
                Conditions=[{'Field': 'path-pattern', 'Values': ['/']}],
                Priority=1,
                Actions=[{'Type': 'redirect', 'RedirectConfig': {'Protocol': redirect_protocol, 'Port': str(redirect_port), 'StatusCode': 'HTTP_301'}}],
                Tags=[{'Key': "Name", 'Value': listener_rule_name}]
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a regra no listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
            rules_response = elbv2_client.describe_rules(ListenerArn=listener_arn)
            print("\n".join(rule['RuleArn'] for rule in rules_response['Rules'] if any(action['Type'] == 'redirect' and action['RedirectConfig']['Protocol'] == redirect_protocol for action in rule.get('Actions', []))))
    else:
        print(f"Não existe um listener que vincula o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2-ELB")
print("LISTENER RULE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"
tg_name = "tgTest1"
listener_protocol = "HTTP"
listener_port = "80"
redirect_protocol = "HTTPS"
redirect_port = 443

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n): ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do load balancer {alb_name}")
    elbv2_client = boto3.client('elbv2')
    lb_response = elbv2_client.describe_load_balancers(Names=[alb_name])
    lb_arn = lb_response['LoadBalancers'][0]['LoadBalancerArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a ARN do target group {tg_name}")
    tg_response = elbv2_client.describe_target_groups(Names=[tg_name])
    tg_arn = tg_response['TargetGroups'][0]['TargetGroupArn']

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um listener vinculando o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
    listeners_response = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)
    if any(listener['Port'] == int(listener_port) and listener['Protocol'] == listener_protocol and any(action['TargetGroupArn'] == tg_arn for action in listener.get('DefaultActions', [])) for listener in listeners_response['Listeners']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do listener cujo protocolo é {listener_protocol} e a porta é {listener_port}")
        listener_arn = next((listener['ListenerArn'] for listener in listeners_response['Listeners'] if listener['Port'] == int(listener_port) and listener['Protocol'] == listener_protocol and any(action['TargetGroupArn'] == tg_arn for action in listener.get('DefaultActions', []))), None)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe uma regra no listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
        rules_response = elbv2_client.describe_rules(ListenerArn=listener_arn)
        if any(action['Type'] == 'redirect' and action['RedirectConfig']['Protocol'] == redirect_protocol for rule in rules_response['Rules'] for action in rule.get('Actions', [])):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as regras do listener de protocolo {listener_protocol} e porta {listener_port}")
            print("\n".join(rule['RuleArn'] for rule in rules_response['Rules']))

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo a ARN da regra do listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
            listener_rule_arn = next((rule['RuleArn'] for rule in rules_response['Rules'] if any(action['Type'] == 'redirect' and action['RedirectConfig']['Protocol'] == redirect_protocol for action in rule.get('Actions', []))), None)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a regra no listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
            elbv2_client.delete_rule(RuleArn=listener_rule_arn)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as regras do listener de protocolo {listener_protocol} e porta {listener_port}")
            rules_response = elbv2_client.describe_rules(ListenerArn=listener_arn)
            print("\n".join(rule['RuleArn'] for rule in rules_response['Rules']))
        else:
            print(f"Não existe a regra no listener redirecionando o tráfego da porta {listener_port} para a porta {redirect_port}")
    else:
        print(f"Não existe um listener que vincula o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
else:
    print("Código não executado")