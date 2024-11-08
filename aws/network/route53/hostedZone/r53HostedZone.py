#!/usr/bin/env python

import boto3
from datetime import datetime

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hosted_zone_reference = "hostedZoneReferenceTest" + datetime.now().strftime("%Y%m%d%H%M%S")
domain_name = "hosted-zone-test1.com.br"  # Um domínio é o nome de um site ou serviço na internet
# domain_name = "pedroheeger.dev.br"
hosted_zone_name = domain_name + "."  # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
description = "Hosted Zone Test 1"
private_zone = False

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53 = boto3.client('route53')
    response = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')
    
    if any(zone['Name'] == hosted_zone_name for zone in response['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a hosted zone {hosted_zone_name}")
        print(response['HostedZones'][0]['Name'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as hosted zones existentes")
        response = route53.list_hosted_zones()
        for zone in response['HostedZones']:
            print(zone['Name'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a hosted zone {hosted_zone_name}")
        route53.create_hosted_zone(
            Name=domain_name,
            CallerReference=hosted_zone_reference,
            HostedZoneConfig={
                'Comment': description,
                'PrivateZone': private_zone
            }
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a hosted zone {hosted_zone_name}")
        response = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')
        print(response['HostedZones'][0]['Name'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("HOSTED ZONE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
domain_name = "hosted-zone-test1.com.br"  # Um domínio é o nome de um site ou serviço na internet
# domain_name = "pedroheeger.dev.br"
hosted_zone_name = domain_name + "."  # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53 = boto3.client('route53')
    response = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')
    
    if any(zone['Name'] == hosted_zone_name for zone in response['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as hosted zones existentes")
        response = route53.list_hosted_zones()
        for zone in response['HostedZones']:
            print(zone['Name'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hosted_zone_id = response['HostedZones'][0]['Id'].split("/")[-1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a hosted zone {hosted_zone_name}")
        route53.delete_hosted_zone(Id=hosted_zone_id)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as hosted zones existentes")
        response = route53.list_hosted_zones()
        for zone in response['HostedZones']:
            print(zone['Name'])
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")