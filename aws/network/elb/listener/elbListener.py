#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ELB")
print("LISTENER CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"
tg_name = "tgTest1"
listener_protocol = "HTTP"
listener_port = "80"
# listener_protocol = "HTTPS"
# listener_port = "443"
full_domain_name = "www.pedroheeger.dev.br"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o target group {tg_name} e o load balancer {alb_name}")
    elbv2_client = boto3.client('elbv2')

    try:
        response = elbv2_client.describe_target_groups(Names=[tg_name])
        target_group_found = len(response['TargetGroups']) > 0
    except ClientError as e:
        target_group_found = False

    try:
        response = elbv2_client.describe_load_balancers(Names=[alb_name])
        lb_found = len(response['LoadBalancers']) > 0
    except ClientError as e:
        lb_found = False

    if target_group_found and lb_found:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do load balancer {alb_name}")
        elbv2_client = boto3.client('elbv2')
        lbArn = elbv2_client.describe_load_balancers(Names=[alb_name])['LoadBalancers'][0]['LoadBalancerArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do target group {tg_name}")
        tgArn = elbv2_client.describe_target_groups(Names=[tg_name])['TargetGroups'][0]['TargetGroupArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe um listener vinculando o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
        matching_listeners = [listener for listener in listeners if listener['Port'] == int(listener_port) and listener['Protocol'] == listener_protocol and any(action['TargetGroupArn'] == tgArn for action in listener['DefaultActions'])]
        if matching_listeners:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe um listener vinculando o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
            print(matching_listeners[0]['ListenerArn'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os listeners do load balancer {alb_name}")
            for listener in listeners:
                print(listener['ListenerArn'])

            if listener_protocol == "HTTPS":
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo a ARN do certificado de domínio {full_domain_name}")
                response = boto3.client('acm').list_certificates()
                certificates = response.get('CertificateSummaryList', [])

                for certificate in certificates:
                    if certificate.get('DomainName') == full_domain_name:
                        certificate_arn = certificate.get('CertificateArn')
                        break

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Criando um listener para vincular o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol} com certificado")
                elbv2_client.create_listener(
                    LoadBalancerArn=lbArn,
                    Protocol=listener_protocol,
                    Port=int(listener_port),
                    DefaultActions=[{'Type': 'forward', 'TargetGroupArn': tgArn}],
                    Certificates=[{'CertificateArn': certificate_arn}]
                )
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Criando um listener para vincular o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
                elbv2_client.create_listener(
                    LoadBalancerArn=lbArn,
                    Protocol=listener_protocol,
                    Port=int(listener_port),
                    DefaultActions=[{'Type': 'forward', 'TargetGroupArn': tgArn}]
                )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o listener que vincula o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
            new_listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
            new_matching_listener = [listener['ListenerArn'] for listener in new_listeners if listener['Port'] == int(listener_port) and listener['Protocol'] == listener_protocol and any(action['TargetGroupArn'] == tgArn for action in listener['DefaultActions'])]
            print(new_matching_listener[0])
    else:
        print(f"Não existe o target group {tg_name} ou o load balancer {alb_name}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS ELB")
print("LISTENER EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
alb_name = "albTest1"
tg_name = "tgTest1"
listener_protocol = "HTTP"
listener_port = "80"
# listener_protocol = "HTTPS"
# listener_port = "443"
full_domain_name = "www.pedroheeger.dev.br"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o target group {tg_name} e o load balancer {alb_name}")
    elbv2_client = boto3.client('elbv2')

    try:
        response = elbv2_client.describe_target_groups(Names=[tg_name])
        target_group_found = len(response['TargetGroups']) > 0
    except ClientError as e:
        target_group_found = False

    try:
        response = elbv2_client.describe_load_balancers(Names=[alb_name])
        lb_found = len(response['LoadBalancers']) > 0
    except ClientError as e:
        lb_found = False

    if target_group_found and lb_found:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do load balancer {alb_name}")
        elbv2_client = boto3.client('elbv2')
        lbArn = elbv2_client.describe_load_balancers(Names=[alb_name])['LoadBalancers'][0]['LoadBalancerArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo a ARN do target group {tg_name}")
        tgArn = elbv2_client.describe_target_groups(Names=[tg_name])['TargetGroups'][0]['TargetGroupArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe um listener vinculando o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
        matching_listeners = [listener for listener in listeners if listener['Port'] == int(listener_port) and listener['Protocol'] == listener_protocol and any(action['TargetGroupArn'] == tgArn for action in listener['DefaultActions'])]
        if matching_listeners:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os listeners do load balancer {alb_name}")
            for listener in listeners:
                print(listener['ListenerArn'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo a ARN do listener que vincula o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
            listenerArn = matching_listeners[0]['ListenerArn']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo listener que vincula o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
            elbv2_client.delete_listener(ListenerArn=listenerArn)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os listeners do load balancer {alb_name}")
            updated_listeners = elbv2_client.describe_listeners(LoadBalancerArn=lbArn)['Listeners']
            for listener in updated_listeners:
                print(listener['ListenerArn'])
            # updated_listener_arns = [listener['ListenerArn'] for listener in updated_listeners]
            # print(updated_listener_arns)
        else:
            print(f"Não existe um listener que vincula o target group {tg_name} ao load balancer {alb_name} na porta {listener_port} do protocolo {listener_protocol}")
    else:
        print(f"Não existe o target group {tg_name} ou o load balancer {alb_name}")
else:
    print("Código não executado")