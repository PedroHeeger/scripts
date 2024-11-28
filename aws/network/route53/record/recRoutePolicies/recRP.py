#!/usr/bin/env python3
import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD ROUTING POLICIES-HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# domain_name = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
domain_name = "pedroheeger.dev.br"
hosted_zone_name = f"{domain_name}."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
subdomain = "www."
resource_record_type = "A"
ttl = 300

# Simple Routing Policy (SRP)
# routing_policy = "SRP"
# subdomain = "rsrp."
# tag_name_instance1 = "ec2Test1"

# Failover Policy (FOP)
routing_policy = "FOP"
# subdomain = "rfop."
tag_name_instance1 = "ec2Test1"
tag_name_instance2 = "ec2Test2"
failover_record_type1 = "PRIMARY"   # PRIMARY OR SECONDARY
failover_record_type2 = "SECONDARY"   # PRIMARY OR SECONDARY
health_check_name = "healthCheckTest1"
record_id1 = "Primary"
record_id2 = "Secondary"
region1 = "us-east-1"
region2 = "sa-east-1"

# Geolocation Policy (GLP)
# routing_policy = "GLP"
# # subdomain = "rglp."
# tag_name_instance1 = "ec2Test1"
# tag_name_instance2 = "ec2Test2"
# record_id1 = "US-NorthVirginia"
# record_id2 = "Brasil-SP"
# country_code1 = "US"
# subdivision_code1 = "VA"
# country_code2 = "BR"
# # country_code2 = "FR"
# region1 = "us-east-1"
# region2 = "sa-east-1"

resource_record_name = f"{subdomain}{domain_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53_client = boto3.client('route53')

    hosted_zones = route53_client.list_hosted_zones()
    if any(zone['Name'] == hosted_zone_name for zone in hosted_zones['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hosted_zone_id = next(zone['Id'] for zone in hosted_zones['HostedZones'] if zone['Name'] == hosted_zone_name)

        def create_record_srp(hosted_zone_id, hosted_zone_name, resource_record_name, resource_record_type, ttl, tag_name_instance):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o registro {resource_record_name} na hosted zone {hosted_zone_name}")
            record_sets = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            existing_record = any(record['Name'] == f"{resource_record_name}." for record in record_sets['ResourceRecordSets'])

            if existing_record:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe o registro {resource_record_name} na hosted zone {hosted_zone_name}")
                for record in record_sets['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}.":
                        print(record)
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros na hosted zone {hosted_zone_name}")
                for record in record_sets['ResourceRecordSets']:
                    print(record['Name'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o IP da instância {tag_name_instance}")
                ec2_client = boto3.client('ec2')
                instances = ec2_client.describe_instances(
                    Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]
                )
                instance_ip = instances['Reservations'][0]['Instances'][0]['PublicIpAddress']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Criando o registro {resource_record_name} na hosted zone {hosted_zone_name}")
                route53_client.change_resource_record_sets(
                    HostedZoneId=hosted_zone_id,
                    ChangeBatch={
                        'Changes': [{
                            'Action': 'CREATE',
                            'ResourceRecordSet': {
                                'Name': resource_record_name,
                                'Type': resource_record_type,
                                'TTL': ttl,
                                'ResourceRecords': [{'Value': instance_ip}]
                            }
                        }]
                    }
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o registro {resource_record_name} na hosted zone {hosted_zone_name}")
                record_sets = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
                for record in record_sets['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}.":
                        print(record)

        def create_record_fop(hosted_zone_id, hosted_zone_name, resource_record_name, record_id, resource_record_type, ttl, failover_record_type, tag_name_instance, health_check_name, region):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
            route53_client = boto3.client('route53')

            response = route53_client.list_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                StartRecordName=resource_record_name,
                StartRecordType=resource_record_type
            )
            condition = [record for record in response['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}." and 'SetIdentifier' in record and record['SetIdentifier'] == record_id]
            
            if len(condition) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                for record in condition:
                    print("Resource Record Name:", record['Name'], " Set Identifier:", record['SetIdentifier'])
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros {resource_record_name} na hosted zone {hosted_zone_name}")
                response = route53_client.list_resource_record_sets(
                    HostedZoneId=hosted_zone_id,
                    StartRecordName=resource_record_name
                )
                for record in response['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}.":
                        print("Resource Record Name:", record['Name'], " Set Identifier:", record['SetIdentifier'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o IP da instância {tag_name_instance}")
                ec2_client = boto3.client('ec2', region_name=region)
                instances = ec2_client.describe_instances(
                    Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]
                )
                instance_ip = instances['Reservations'][0]['Instances'][0]['PublicIpAddress']
                
                if health_check_name:
                    print("Extraindo o ID da verificação de integridade", health_check_name)
                    health_check_response = route53_client.list_health_checks()
                    health_check_id = next((hc['Id'] for hc in health_check_response['HealthChecks'] if hc['CallerReference'] == health_check_name), None)

                    if health_check_id:
                        print("-----//-----//-----//-----//-----//-----//-----")
                        print(f"Criando o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                        route53_client.change_resource_record_sets(
                            HostedZoneId=hosted_zone_id,
                            ChangeBatch={
                                'Changes': [
                                    {
                                        'Action': 'CREATE',
                                        'ResourceRecordSet': {
                                            'Name': resource_record_name,
                                            'Type': resource_record_type,
                                            'TTL': ttl,
                                            'ResourceRecords': [{'Value': instance_ip}],
                                            'SetIdentifier': record_id,
                                            'Failover': failover_record_type,
                                            'HealthCheckId': health_check_id
                                        }
                                    }
                                ]
                            }
                        )
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Criando o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                    route53_client.change_resource_record_sets(
                        HostedZoneId=hosted_zone_id,
                        ChangeBatch={
                            'Changes': [
                                {
                                    'Action': 'CREATE',
                                    'ResourceRecordSet': {
                                        'Name': resource_record_name,
                                        'Type': resource_record_type,
                                        'TTL': ttl,
                                        'ResourceRecords': [{'Value': instance_ip}],
                                        'SetIdentifier': record_id,
                                        'Failover': failover_record_type
                                    }
                                }
                            ]
                        }
                    )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                response = route53_client.list_resource_record_sets(
                    HostedZoneId=hosted_zone_id,
                    StartRecordName=resource_record_name,
                    StartRecordType=resource_record_type
                )
                for record in response['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}." and 'SetIdentifier' in record and record['SetIdentifier'] == record_id:
                        print("Resource Record Name:", record['Name'], " Set Identifier:", record['SetIdentifier'])


        def create_record_glp(hosted_zone_id, hosted_zone_name, resource_record_name, record_id, resource_record_type, ttl, tag_name_instance, country_code, subdivision_code, region):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
            route53 = boto3.client('route53')
            condition = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            
            if any(record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id for record in condition['ResourceRecordSets']):
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                for record in condition['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id:
                        print(record['SetIdentifier'])
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros {resource_record_name} na hosted zone {hosted_zone_name}")
                for record in condition['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}.":
                        print(record['SetIdentifier'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o IP da instância {tag_name_instance}")
                ec2 = boto3.client('ec2', region_name=region)
                response = ec2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}])
                instance_ip = response['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

                if not subdivision_code:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Criando o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                    route53.change_resource_record_sets(
                        HostedZoneId=hosted_zone_id,
                        ChangeBatch={
                            'Changes': [
                                {
                                    'Action': 'CREATE',
                                    'ResourceRecordSet': {
                                        'Name': f"{resource_record_name}.",
                                        'Type': resource_record_type,
                                        'TTL': ttl,
                                        'ResourceRecords': [{'Value': instance_ip}],
                                        'SetIdentifier': record_id,
                                        'GeoLocation': {'CountryCode': country_code}
                                    }
                                }
                            ]
                        }
                    )
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Criando o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                    route53.change_resource_record_sets(
                        HostedZoneId=hosted_zone_id,
                        ChangeBatch={
                            'Changes': [
                                {
                                    'Action': 'CREATE',
                                    'ResourceRecordSet': {
                                        'Name': f"{resource_record_name}.",
                                        'Type': resource_record_type,
                                        'TTL': ttl,
                                        'ResourceRecords': [{'Value': instance_ip}],
                                        'SetIdentifier': record_id,
                                        'GeoLocation': {
                                            'CountryCode': country_code,
                                            'SubdivisionCode': subdivision_code
                                        }
                                    }
                                }
                            ]
                        }
                    )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                condition = route53.list_resource_record_sets(HostedZoneId=hosted_zone_id)
                for record in condition['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id:
                        print(record['SetIdentifier'])




        route53 = boto3.client('route53')
        ec2 = boto3.client('ec2', region_name=region1)
        if routing_policy == "SRP":
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe a instância {tag_name_instance1}")
            instance_exists = len(ec2.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}, {'Name': 'instance-state-name', 'Values': ['running']}]
            )['Reservations']) > 0

            if instance_exists:
                create_record_srp(hosted_zone_id, hosted_zone_name, resource_record_name, resource_record_type, ttl, tag_name_instance1)
            else:
                print(f"Não existe a hosted zone {hosted_zone_name} ou a instância {tag_name_instance1}")

        elif routing_policy == "FOP":
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe a verificação de integridade {health_check_name} e as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")
            health_check_exists = len(route53.list_health_checks()['HealthChecks']) > 0
            instance1_exists = len(ec2.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}, {'Name': 'instance-state-name', 'Values': ['running']}]
            )['Reservations']) > 0

            ec2_other_region = boto3.client('ec2', region_name=region2)
            instance2_exists = len(ec2_other_region.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance2]}, {'Name': 'instance-state-name', 'Values': ['running']}]
            )['Reservations']) > 0

            if health_check_exists and instance1_exists and instance2_exists:
                create_record_fop(hosted_zone_id, hosted_zone_name, resource_record_name, record_id1, resource_record_type, ttl, failover_record_type1, tag_name_instance1, health_check_name, region1)
                create_record_fop(hosted_zone_id, hosted_zone_name, resource_record_name, record_id2, resource_record_type, ttl, failover_record_type2, tag_name_instance2, "", region2)
            else:
                print(f"Não existe a verificação de integridade {health_check_name} ou as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")

        elif routing_policy == "GLP":
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")
            instance1_exists = len(ec2.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}, {'Name': 'instance-state-name', 'Values': ['running']}],
            )['Reservations']) > 0

            ec2_other_region = boto3.client('ec2', region_name=region2)
            instance2_exists = len(ec2_other_region.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance2]}, {'Name': 'instance-state-name', 'Values': ['running']}],
            )['Reservations']) > 0

            if instance1_exists and instance2_exists:
                create_record_glp(hosted_zone_id, hosted_zone_name, resource_record_name, record_id1, resource_record_type, ttl, tag_name_instance1, country_code1, subdivision_code1, region1)
                create_record_glp(hosted_zone_id, hosted_zone_name, resource_record_name, record_id2, resource_record_type, ttl, tag_name_instance2, country_code2, "", region2)
            else:
                print(f"Não existem as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")
        else:
            print(f"Não existe o tipo de roteamento {routing_policy}")
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD ROUTING POLICIES-HOSTED ZONE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# domain_name = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
domain_name = "pedroheeger.dev.br"
hosted_zone_name = f"{domain_name}."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
subdomain = "www."
resource_record_type = "A"
ttl = 300

# Simple Routing Policy (SRP)
# routing_policy = "SRP"
# subdomain = "rsrp."
# tag_name_instance1 = "ec2Test1"

# Failover Policy (FOP)
routing_policy = "FOP"
# subdomain = "rfop."
tag_name_instance1 = "ec2Test1"
tag_name_instance2 = "ec2Test2"
failover_record_type1 = "PRIMARY"  # PRIMARY OR SECONDARY
failover_record_type2 = "SECONDARY"  # PRIMARY OR SECONDARY
health_check_name = "healthCheckTest1"
record_id1 = "Primary"
record_id2 = "Secondary"
region1 = "us-east-1"
region2 = "sa-east-1"

# Geolocation Policy (GLP)
# routing_policy = "GLP"
# # subdomain = "rglp."
# tag_name_instance1 = "ec2Test1"
# tag_name_instance2 = "ec2Test2"
# record_id1 = "US-NorthVirginia"
# record_id2 = "Brasil-SP"
# country_code1 = "US"
# subdivision_code1 = "VA"
# country_code2 = "BR"
# # country_code2 = "FR"
# region1 = "us-east-1"
# region2 = "sa-east-1"

resource_record_name = f"{subdomain}{domain_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53 = boto3.client('route53')

    hosted_zones = route53.list_hosted_zones()
    if any(zone['Name'] == hosted_zone_name for zone in hosted_zones['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hosted_zone_id = next(zone['Id'] for zone in hosted_zones['HostedZones'] if zone['Name'] == hosted_zone_name)

        def delete_record_srp(hosted_zone_id, hosted_zone_name, resource_record_name, resource_record_type, ttl, tag_name_instance):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o registro {resource_record_name} na hosted zone {hosted_zone_name}")
            route53 = boto3.client('route53')
            response = route53.list_resource_record_sets(
                HostedZoneId=hosted_zone_id
            )
            condition = any(record['Name'] == f"{resource_record_name}." for record in response['ResourceRecordSets'])
            
            if condition:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros na hosted zone {hosted_zone_name}")
                for record in response['ResourceRecordSets']:
                    print(record['Name'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe uma instância ativa {tag_name_instance}")
                ec2 = boto3.client('ec2')
                response = ec2.describe_instances(
                    Filters=[
                        {'Name': 'tag:Name', 'Values': [tag_name_instance]},
                        {'Name': 'instance-state-name', 'Values': ['running']}
                    ]
                )
                
                if response['Reservations']:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Extraindo o IP da instância {tag_name_instance}")
                    instance_ip = response['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association'][0]['PublicIp']
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Extraindo o IP da instância {tag_name_instance} configurado no registro {resource_record_name}")
                    instance_ip = next((record['ResourceRecords'][0]['Value'] for record in response['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}."), None)

                if instance_ip:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Removendo o registro {resource_record_name} na hosted zone {hosted_zone_name}")
                    route53.change_resource_record_sets(
                        HostedZoneId=hosted_zone_id,
                        ChangeBatch={
                            "Changes": [
                                {
                                    "Action": "DELETE",
                                    "ResourceRecordSet": {
                                        "Name": f"{resource_record_name}",
                                        "Type": resource_record_type,
                                        "TTL": ttl,
                                        "ResourceRecords": [
                                            {"Value": instance_ip}
                                        ]
                                    }
                                }
                            ]
                        }
                    )

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando todos os registros na hosted zone {hosted_zone_name}")
                    response = route53.list_resource_record_sets(
                        HostedZoneId=hosted_zone_id
                    )
                    for record in response['ResourceRecordSets']:
                        print(record['Name'])
            else:
                print(f"Não existe o registro {resource_record_name} na hosted zone {hosted_zone_name}")

        def delete_record_fop(hosted_zone_id, hosted_zone_name, resource_record_name, record_id, resource_record_type, ttl, failover_record_type, tag_name_instance, region, health_check_name=None):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
            route53 = boto3.client('route53')
            response = route53.list_resource_record_sets(
                HostedZoneId=hosted_zone_id
            )
            condition = any(
                record['Name'] == f"{resource_record_name}." and record.get('SetIdentifier') == record_id
                for record in response['ResourceRecordSets']
            )
            
            if condition:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros {resource_record_name} na hosted zone {hosted_zone_name}")
                for record in response['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}.":
                        print(record.get('SetIdentifier'))

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe uma instância ativa {tag_name_instance}")
                ec2 = boto3.client('ec2', region_name=region)
                response = ec2.describe_instances(
                    Filters=[
                        {'Name': 'tag:Name', 'Values': [tag_name_instance]},
                        {'Name': 'instance-state-name', 'Values': ['running']}
                    ]
                )

                if response['Reservations']:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Extraindo o IP da instância {tag_name_instance}")
                    instance_ip = response['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Extraindo o IP da instância {tag_name_instance} configurado no registro {resource_record_name}")
                    instance_ip = next(
                        (record['ResourceRecords'][0]['Value'] for record in response['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}." and record.get('SetIdentifier') == record_id),
                        None
                    )

                if health_check_name:
                    print(f"Extraindo o ID da verificação de integridade {health_check_name}")
                    health_check_response = route53.list_health_checks()
                    health_check_id = next(
                        (hc['Id'] for hc in health_check_response['HealthChecks'] if hc['CallerReference'] == health_check_name),
                        None
                    )

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Removendo o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                    route53.change_resource_record_sets(
                        HostedZoneId=hosted_zone_id,
                        ChangeBatch={
                            "Changes": [
                                {
                                    "Action": "DELETE",
                                    "ResourceRecordSet": {
                                        "Name": f"{resource_record_name}",
                                        "Type": resource_record_type,
                                        "TTL": ttl,
                                        "ResourceRecords": [
                                            {"Value": instance_ip}
                                        ],
                                        "SetIdentifier": record_id,
                                        "Failover": failover_record_type,
                                        "HealthCheckId": health_check_id
                                    }
                                }
                            ]
                        }
                    )
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Removendo o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                    route53.change_resource_record_sets(
                        HostedZoneId=hosted_zone_id,
                        ChangeBatch={
                            "Changes": [
                                {
                                    "Action": "DELETE",
                                    "ResourceRecordSet": {
                                        "Name": f"{resource_record_name}",
                                        "Type": resource_record_type,
                                        "TTL": ttl,
                                        "ResourceRecords": [
                                            {"Value": instance_ip}
                                        ],
                                        "SetIdentifier": record_id,
                                        "Failover": failover_record_type
                                    }
                                }
                            ]
                        }
                    )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros {resource_record_name} na hosted zone {hosted_zone_name}")
                response = route53.list_resource_record_sets(
                    HostedZoneId=hosted_zone_id
                )
                for record in response['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}.":
                        print(record.get('SetIdentifier'))
            else:
                print(f"Não existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")


        def delete_record_glp(hosted_zone_id, hosted_zone_name, resource_record_name, record_id, resource_record_type, ttl, tag_name_instance, country_code, subdivision_code, region):
            client_route53 = boto3.client('route53')

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
            condition = client_route53.list_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                StartRecordName=resource_record_name,
                StartRecordType=resource_record_type
            )
            
            record_sets = [record for record in condition['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}." and 'SetIdentifier' in record and record['SetIdentifier'] == record_id]
            
            if len(record_sets) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros {resource_record_name} na hosted zone {hosted_zone_name}")
                for record in record_sets:
                    print(record['SetIdentifier'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe uma instância ativa {tag_name_instance}")
                client_ec2 = boto3.client('ec2', region_name=region)
                instances = client_ec2.describe_instances(
                    Filters=[
                        {'Name': 'tag:Name', 'Values': [tag_name_instance]},
                        {'Name': 'instance-state-name', 'Values': ['running']}
                    ]
                )

                if len(instances['Reservations']) > 0:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Extraindo o IP da instância {tag_name_instance}")
                    instance_ip = instances['Reservations'][0]['Instances'][0]['PublicIpAddress']
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Extraindo o IP da instância {tag_name_instance} configurado no registro {resource_record_name}")
                    instance_ip = next(
                        (record['ResourceRecords'][0]['Value'] for record in record_sets), None
                    )

                if not subdivision_code:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Removendo o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                    change_batch = {
                        "Changes": [
                            {
                                "Action": "DELETE",
                                "ResourceRecordSet": {
                                    "Name": resource_record_name,
                                    "Type": resource_record_type,
                                    "TTL": ttl,
                                    "ResourceRecords": [{"Value": instance_ip}],
                                    "SetIdentifier": record_id,
                                    "GeoLocation": {
                                        "CountryCode": country_code
                                    }
                                }
                            }
                        ]
                    }
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Removendo o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")
                    change_batch = {
                        "Changes": [
                            {
                                "Action": "DELETE",
                                "ResourceRecordSet": {
                                    "Name": resource_record_name,
                                    "Type": resource_record_type,
                                    "TTL": ttl,
                                    "ResourceRecords": [{"Value": instance_ip}],
                                    "SetIdentifier": record_id,
                                    "GeoLocation": {
                                        "CountryCode": country_code,
                                        "SubdivisionCode": subdivision_code
                                    }
                                }
                            }
                        ]
                    }

                client_route53.change_resource_record_sets(
                    HostedZoneId=hosted_zone_id,
                    ChangeBatch=change_batch
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os registros {resource_record_name} na hosted zone {hosted_zone_name}")
                condition = client_route53.list_resource_record_sets(
                    HostedZoneId=hosted_zone_id,
                    StartRecordName=resource_record_name,
                    StartRecordType=resource_record_type
                )
                for record in condition['ResourceRecordSets']:
                    if record['Name'] == f"{resource_record_name}.":
                        print(record['SetIdentifier'])

            else:
                print(f"Não existe o registro {resource_record_name} com identificador {record_id} na hosted zone {hosted_zone_name}")




        route53 = boto3.client('route53')
        ec2 = boto3.client('ec2', region_name=region1)
        if routing_policy == "SRP":
            # print("-----//-----//-----//-----//-----//-----//-----")
            # print(f"Verificando se existe a instância {tag_name_instance1}")
            # instances_running_1 = len(ec2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}, {'Name': 'instance-state-name', 'Values': ['running']}])['Reservations']) > 0
            # if instances_running_1:
                delete_record_srp(hosted_zone_id, hosted_zone_name, resource_record_name, resource_record_type, ttl, tag_name_instance1)
            # else:
            #     print(f"Não existe a instância {tag_name_instance1}")

        elif routing_policy == "FOP":
            # print("-----//-----//-----//-----//-----//-----//-----")
            # print(f"Verificando se existe a verificação de integridade {health_check_name} e as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")
            # health_check_exists = len(route53.list_health_checks()['HealthChecks']) > 0
            # instances_running_1 = len(ec2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}, {'Name': 'instance-state-name', 'Values': ['running']}])['Reservations']) > 0

            # ec2_other_region = boto3.client('ec2', region_name=region2)
            # instances_running_2 = len(ec2_other_region.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance2]}, {'Name': 'instance-state-name', 'Values': ['running']}])['Reservations']) > 0
            
            # if health_check_exists and instances_running_1 and instances_running_2:
                delete_record_fop(hosted_zone_id, hosted_zone_name, resource_record_name, record_id1, resource_record_type, ttl, failover_record_type1, tag_name_instance1, region1, health_check_name)
                delete_record_fop(hosted_zone_id, hosted_zone_name, resource_record_name, record_id2, resource_record_type, ttl, failover_record_type2, tag_name_instance2, region2)
            # else:
            #     print(f"Não existe a verificação de integridade {health_check_name} ou as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")

        elif routing_policy == "GLP":
            # print("-----//-----//-----//-----//-----//-----//-----")
            # print(f"Verificando se existe as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")
            # instances_running_1 = len(ec2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}, {'Name': 'instance-state-name', 'Values': ['running']}])['Reservations']) > 0

            # ec2_other_region = boto3.client('ec2', region_name=region2)
            # instances_running_2 = len(ec2_other_region.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance2]}, {'Name': 'instance-state-name', 'Values': ['running']}])['Reservations']) > 0
            
            # if instances_running_1 and instances_running_2:
                delete_record_glp(hosted_zone_id, hosted_zone_name, resource_record_name, record_id1, resource_record_type, ttl, tag_name_instance1, country_code1, subdivision_code1, region1)
                delete_record_glp(hosted_zone_id, hosted_zone_name, resource_record_name, record_id2, resource_record_type, ttl, tag_name_instance2, country_code2, "", region2)
            # else:
            #     print(f"Não existem as instâncias ativas {tag_name_instance1} e {tag_name_instance2}")
        else:
            print(f"Não existe o tipo de roteamento {routing_policy}")
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")