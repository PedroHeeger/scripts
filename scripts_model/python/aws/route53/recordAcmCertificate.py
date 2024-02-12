#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD ACM CERTIFICATE-HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# hosted_zone_name = "hosted-zone-test2.com.br."
# domain_name = "hosted-zone-test2.com.br"
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    route53 = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    response_hosted_zones = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')

    if response_hosted_zones['HostedZones']:
        hosted_zone = response_hosted_zones['HostedZones'][0]
        hosted_zone_id = hosted_zone['Id'].split("/")[-1]


        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cliente para o serviço ACM")
        acm = boto3.client('acm', region_name='us-east-1') 

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe um certificado para o domínio {domain_name}")
        response_certificates = acm.list_certificates(CertificateStatuses=['ISSUED', 'PENDING_VALIDATION'])

        existing_certificates = [cert['DomainName'] for cert in response_certificates['CertificateSummaryList']]
        if domain_name in existing_certificates:
            certificate_arn = response_certificates['CertificateSummaryList'][existing_certificates.index(domain_name)]['CertificateArn']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ARN do certificado para o domínio {domain_name}")
            
            resource_record_name = acm.describe_certificate(CertificateArn=certificate_arn)['Certificate']['DomainValidationOptions'][0]['ResourceRecord']['Name']
            resource_record_value = acm.describe_certificate(CertificateArn=certificate_arn)['Certificate']['DomainValidationOptions'][0]['ResourceRecord']['Value']
        else:
            print("Não existe o certificado para o domínio {domain_name}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
        response_resource_record_sets = route53.list_resource_record_sets(HostedZoneId=hosted_zone_id, StartRecordName=f"{resource_record_name}.", StartRecordType='CNAME', MaxItems='1')

        if response_resource_record_sets['ResourceRecordSets']:
            existing_record_name = response_resource_record_sets['ResourceRecordSets'][0]['Name']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {existing_record_name} na hosted zone {hosted_zone_name}")
            print(existing_record_name)
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")

            response_all_records = route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            all_record_names = [record['Name'] for record in response_all_records['ResourceRecordSets']]
            
            for record_name in all_record_names:
                print(record_name)

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
                            "ResourceRecords": [
                                {"Value": resource_record_value}
                            ]
                        }
                    }
                ]
            }

            route53.change_resource_record_sets(HostedZoneId=hosted_zone_id, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            response_created_record = route53.list_resource_record_sets(HostedZoneId=hosted_zone_id, StartRecordName=f"{resource_record_name}.", StartRecordType='CNAME', MaxItems='1')

            created_record_name = response_created_record['ResourceRecordSets'][0]['Name']
            print(created_record_name)
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD ACM CERTIFICATE-HOSTED ZONE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# hosted_zone_name = "hosted-zone-test2.com.br."
# domain_name = "hosted-zone-test2.com.br"
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    route53 = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    response_hosted_zones = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')

    if response_hosted_zones['HostedZones']:
        hosted_zone = response_hosted_zones['HostedZones'][0]
        hosted_zone_id = hosted_zone['Id'].split("/")[-1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cliente para o serviço ACM")
        acm = boto3.client('acm', region_name='us-east-1')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe um certificado para o domínio {domain_name}")
        response_certificates = acm.list_certificates(CertificateStatuses=['ISSUED', 'PENDING_VALIDATION'])

        existing_certificates = [cert['DomainName'] for cert in response_certificates['CertificateSummaryList']]
        if domain_name in existing_certificates:
            certificate_arn = response_certificates['CertificateSummaryList'][existing_certificates.index(domain_name)]['CertificateArn']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ARN do certificado para o domínio {domain_name}")
            resource_record_name = acm.describe_certificate(CertificateArn=certificate_arn)['Certificate']['DomainValidationOptions'][0]['ResourceRecord']['Name']
            resource_record_value = acm.describe_certificate(CertificateArn=certificate_arn)['Certificate']['DomainValidationOptions'][0]['ResourceRecord']['Value']
        else:
            print(f"Não existe o certificado para o domínio {domain_name}")


        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")

        response_resource_record_sets = route53.list_resource_record_sets(HostedZoneId=hosted_zone_id, StartRecordName=f"{resource_record_name}.", StartRecordType='CNAME', MaxItems='1')

        if response_resource_record_sets['ResourceRecordSets']:
            existing_record_name = response_resource_record_sets['ResourceRecordSets'][0]['Name']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            for record_set in response_resource_record_sets['ResourceRecordSets']:
                print(record_set['Name'])

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
                            "ResourceRecords": [
                                {"Value": resource_record_value}
                            ]
                        }
                    }
                ]
            }

            route53.change_resource_record_sets(HostedZoneId=hosted_zone_id, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            response_all_records = route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            for record_set in response_all_records['ResourceRecordSets']:
                print(record_set['Name'])

        else:
            print(f"Não existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")