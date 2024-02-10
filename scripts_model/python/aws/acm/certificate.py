#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ACM")
print("CERTIFICATE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# domain_name = "hosted-zone-test2.com.br"
domain_name = "pedroheeger.dev.br"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ACM")
    acm = boto3.client('acm', region_name='us-east-1')
    
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um certificado para o domínio de nome {domain_name}")
    response = acm.list_certificates(CertificateStatuses=['ISSUED', 'PENDING_VALIDATION'])
    
    existing_certificates = [cert['DomainName'] for cert in response['CertificateSummaryList']]
    
    if domain_name in existing_certificates:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe um certificado para o domínio de nome {domain_name}")
        print(domain_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando os nomes de domínio de todos os certificados existentes")
        for cert in existing_certificates:
            print(cert)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um certificado para o domínio de nome {domain_name}")
        
        response = acm.request_certificate(
            DomainName=domain_name,
            ValidationMethod='DNS'
        )

        certificate_arn = response['CertificateArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando um certificado para o domínio de nome {domain_name}")
        print(domain_name)
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS ACM")
print("CERTIFICATE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# domain_name = "hosted-zone-test2.com.br"
domain_name = "pedroheeger.dev.br"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ACM")
    acm = boto3.client('acm', region_name='us-east-1')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um certificado para o domínio de nome {domain_name}")
    response = acm.list_certificates(CertificateStatuses=['ISSUED', 'PENDING_VALIDATION'])

    existing_certificates = [cert['DomainName'] for cert in response['CertificateSummaryList']]

    if domain_name in existing_certificates:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando os nomes de domínio de todos os certificados existentes")
        for cert in existing_certificates:
            print(cert)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ARN do certificado para o domínio de nome {domain_name}")
        certificate_arn = response['CertificateSummaryList'][existing_certificates.index(domain_name)]['CertificateArn']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o certificado para o domínio de nome {domain_name}")
        acm.delete_certificate(CertificateArn=certificate_arn)
        time.sleep(5)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando os nomes de domínio de todos os certificados existentes")
        response = acm.list_certificates(CertificateStatuses=['ISSUED', 'PENDING_VALIDATION'])
        for cert in response['CertificateSummaryList']:
            print(cert['DomainName'])
    else:
        print(f"Não existe o certificado para o domínio de nome {domain_name}")
else:
    print("Código não executado")