#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD LOAD BALANCER-HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# domain_name = "hosted-zone-test1.com.br"  # Um domínio é o nome de um site ou serviço na internet
domain_name = "pedroheeger.dev.br"
hosted_zone_name = domain_name + "."  # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
elb_name = "albTest1"
# elb_name = "clbTest1"
# subdomain = "ralb."
subdomain = "www."
resource_record_name = f"{subdomain}{domain_name}"
ttl = "300"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    client_route53 = boto3.client('route53')
    response_route53 = client_route53.list_hosted_zones_by_name(DNSName=hosted_zone_name)
    hosted_zone_exists = any(zone['Name'] == hosted_zone_name for zone in response_route53['HostedZones'])
    if hosted_zone_exists:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hosted_zone_id = next(zone['Id'] for zone in response_route53['HostedZones'] if zone['Name'] == hosted_zone_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o load balancer {elb_name}")
        client_elbv2 = boto3.client('elbv2')
        response_elbv2 = client_elbv2.describe_load_balancers()
        load_balancer_exists = any(lb['LoadBalancerName'] == elb_name for lb in response_elbv2['LoadBalancers'])

        if load_balancer_exists:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o DNS do load balancer {elb_name}")
            lb_dns = response_elbv2['LoadBalancers'][0]['DNSName']
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o DNS do load balancer {elb_name} configurado no registro de nome {resource_record_name}")
            response = client_route53.list_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                StartRecordName=resource_record_name,
                MaxItems='1'
            )
            lb_dns = response['ResourceRecordSets'][0]['ResourceRecords'][0]['Value']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
        resource_records = client_route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)['ResourceRecordSets']
        desired_records = [record_set for record_set in resource_records if record_set['Name'] == f"{resource_record_name}."]
        if desired_records:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            print(desired_records[0]['Name'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            all_records = client_route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)['ResourceRecordSets']
            for record in all_records:
                print(record['Name'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            change_batch = {
                "Changes": [
                    {
                        "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": resource_record_name,
                            "Type": "CNAME",
                            "TTL": ttl,
                            "ResourceRecords": [{"Value": lb_dns}]
                        }
                    }
                ]
            }
            client_route53.change_resource_record_sets(HostedZoneId=hosted_zone_id, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            new_resource_records = client_route53.list_resource_record_sets(HostedZoneId=hosted_zone_id, StartRecordName=f"{resource_record_name}.", StartRecordType='CNAME')['ResourceRecordSets']
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
# domain_name = "hosted-zone-test1.com.br"  # Um domínio é o nome de um site ou serviço na internet
domain_name = "pedroheeger.dev.br"
hosted_zone_name = domain_name + "."  # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
elb_name = "albTest1"
# elb_name = "clbTest1"
# subdomain = "ralb."
subdomain = "www."
resource_record_name = f"{subdomain}{domain_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    client_route53 = boto3.client('route53')
    response_route53 = client_route53.list_hosted_zones_by_name(DNSName=hosted_zone_name)
    hosted_zone_exists = any(zone['Name'] == hosted_zone_name for zone in response_route53['HostedZones'])
    if hosted_zone_exists:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hosted_zone_id = next(zone['Id'] for zone in response_route53['HostedZones'] if zone['Name'] == hosted_zone_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o load balancer {elb_name}")
        client_elbv2 = boto3.client('elbv2')
        response_elbv2 = client_elbv2.describe_load_balancers()
        load_balancer_exists = any(lb['LoadBalancerName'] == elb_name for lb in response_elbv2['LoadBalancers'])

        if load_balancer_exists:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o DNS do load balancer {elb_name}")
            lb_dns = response_elbv2['LoadBalancers'][0]['DNSName']
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o DNS do load balancer {elb_name} configurado no registro de nome {resource_record_name}")
            response = client_route53.list_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                StartRecordName=resource_record_name,
                MaxItems='1'
            )
            lb_dns = response['ResourceRecordSets'][0]['ResourceRecords'][0]['Value']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
        resource_records = client_route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)['ResourceRecordSets']
        desired_records = [record_set for record_set in resource_records if record_set['Name'] == f"{resource_record_name}."]
        if desired_records:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            all_records = client_route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)['ResourceRecordSets']
            for record in all_records:
                print(record['Name'])

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
                            "ResourceRecords": [{"Value": lb_dns}]
                        }
                    }
                ]
            }

            client_route53.change_resource_record_sets(HostedZoneId=hosted_zone_id, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            updated_records = client_route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)['ResourceRecordSets']
            for record in updated_records:
                print(record['Name'])
        else:
            print(f"Não existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")