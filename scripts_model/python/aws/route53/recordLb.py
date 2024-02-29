#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD LOAD BALANCER-HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# hosted_zone_name = "hosted-zone-test2.com.br."
# domain_name = "hosted-zone-test2.com.br"
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"
resource_record_name = "recordnamelbtest1.pedroheeger.dev.br"
alb_name = "albTest1"

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    route53_client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    hosted_zones = route53_client.list_hosted_zones_by_name(DNSName=hosted_zone_name)['HostedZones']

    if hosted_zones:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hostedZoneId = hosted_zones[0]['Id'].split('/')[-1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o DNS do load balancer {alb_name}")
        elbv2_client = boto3.client('elbv2')
        lbDNS = elbv2_client.describe_load_balancers(Names=[alb_name])['LoadBalancers'][0]['DNSName']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
        resource_records = route53_client.list_resource_record_sets(HostedZoneId=hostedZoneId)['ResourceRecordSets']
        desired_records = [record_set for record_set in resource_records if record_set['Name'] == f"{resource_record_name}."]

        if desired_records:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            print(desired_records[0]['Name'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            all_records = route53_client.list_resource_record_sets(HostedZoneId=hostedZoneId)['ResourceRecordSets']
            print([record['Name'] for record in all_records])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            change_batch = {
                "Changes": [
                    {
                        "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": resource_record_name,
                            "Type": "CNAME",
                            "TTL": 300,
                            "ResourceRecords": [{"Value": lbDNS}]
                        }
                    }
                ]
            }

            route53_client.change_resource_record_sets(HostedZoneId=hostedZoneId, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            new_resource_records = route53_client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=f"{resource_record_name}.", StartRecordType='CNAME')['ResourceRecordSets']
            print(new_resource_records[0]['Name'])
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD LOAD BALANCER-HOSTED ZONE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# hosted_zone_name = "hosted-zone-test2.com.br."
# domain_name = "hosted-zone-test2.com.br"
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"
resource_record_name = "recordnamelbtest1.pedroheeger.dev.br"
alb_name = "albTest1"

resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    route53_client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    hosted_zones = route53_client.list_hosted_zones_by_name(DNSName=hosted_zone_name)['HostedZones']

    if hosted_zones:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hostedZoneId = hosted_zones[0]['Id'].split('/')[-1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o DNS do load balancer {alb_name}")
        elbv2_client = boto3.client('elbv2')
        lbDNS = elbv2_client.describe_load_balancers(Names=[alb_name])['LoadBalancers'][0]['DNSName']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
        resource_records = route53_client.list_resource_record_sets(HostedZoneId=hostedZoneId)['ResourceRecordSets']
        desired_records = [record_set for record_set in resource_records if record_set['Name'] == f"{resource_record_name}."]

        if desired_records:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            all_records = route53_client.list_resource_record_sets(HostedZoneId=hostedZoneId)['ResourceRecordSets']
            print([record['Name'] for record in all_records])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            change_batch = {
                "Changes": [
                    {
                        "Action": "DELETE",
                        "ResourceRecordSet": {
                            "Name": resource_record_name,
                            "Type": "CNAME",
                            "TTL": 300,
                            "ResourceRecords": [{"Value": lbDNS}]
                        }
                    }
                ]
            }

            route53_client.change_resource_record_sets(HostedZoneId=hostedZoneId, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            updated_records = route53_client.list_resource_record_sets(HostedZoneId=hostedZoneId)['ResourceRecordSets']
            print([record['Name'] for record in updated_records])

        else:
            print(f"Não existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")