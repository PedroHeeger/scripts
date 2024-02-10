#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# hosted_zone_name = "hosted-zone-test2.com.br."
# domain_name = "hosted-zone-test2.com.br"
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"
hosted_zone_reference = "hostedZoneReferenceTest2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    route53 = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone de nome {hosted_zone_name}")
    response = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')
    
    if response['HostedZones']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a hosted zone de nome {hosted_zone_name}")
        print(response['HostedZones'][0]['Name'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as hosted zones existentes")
        response = route53.list_hosted_zones()
        for zone in response['HostedZones']:
            print(zone['Name'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a hosted zone de nome {hosted_zone_name}")
        route53.create_hosted_zone(
            Name=domain_name,
            CallerReference=hosted_zone_reference,
            HostedZoneConfig={'Comment': 'Created by Python script'}
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a hosted zone de nome {hosted_zone_name}")
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
# hosted_zone_name = "hosted-zone-test1.com.br."
hosted_zone_name = "pedroheeger.dev.br."

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    route53 = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone de nome {hosted_zone_name}")
    response = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')
    
    if response['HostedZones']:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as hosted zones existentes")
        response = route53.list_hosted_zones()
        for zone in response['HostedZones']:
            print(zone['Name'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone de nome {hosted_zone_name}")
        hosted_zone_id = response['HostedZones'][0]['Id'].split("/")[-1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a hosted zone de nome {hosted_zone_name}")
        route53.delete_hosted_zone(Id=hosted_zone_id)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as hosted zones existentes")
        response = route53.list_hosted_zones()
        for zone in response['HostedZones']:
            print(zone['Name'])
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")