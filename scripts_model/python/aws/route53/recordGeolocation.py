import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD GEOLOCATION-HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"
resource_record_name = "www.pedroheeger.dev.br"
resource_record_type = "A"
ttl = 300
tag_name_instance1 = "ec2Test1"
tag_name_instance2 = "ec2Test2"
record_id1 = "US-NorthVirginia"
record_id2 = "Europe-Paris"
country_code1 = "US"
country_code2 = "FR"
subdivision_code1 = "VA"
region1 = "us-east-1"
region2 = "eu-west-3"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53_client = boto3.client('route53')
    ec2_client1 = boto3.client('ec2', region_name=region1)
    ec2_client2 = boto3.client('ec2', region_name=region2)

    hosted_zones = route53_client.list_hosted_zones()
    if any(zone['Name'] == hosted_zone_name for zone in hosted_zones['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hosted_zone_id = next(zone['Id'] for zone in hosted_zones['HostedZones'] if zone['Name'] == hosted_zone_name)

        # PRIMARY INSTANCE
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} com identificador {record_id1} na hosted zone {hosted_zone_name}")
        records = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
        
        if any(record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id1 for record in records['ResourceRecordSets']):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {resource_record_name} com identificador {record_id1} na hosted zone {hosted_zone_name}")
            existing_records = [record['SetIdentifier'] for record in records['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id1]
            print(f"Identificadores existentes: {existing_records}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            existing_records = [record['SetIdentifier'] for record in records['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}."]
            print(f"Identificadores: {existing_records}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o IP da instância {tag_name_instance1}")
            instance1 = ec2_client1.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}])
            instance_ip1 = instance1['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o registro de nome {resource_record_name} com identificador {record_id1} na hosted zone {hosted_zone_name}")
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
                                'ResourceRecords': [{'Value': instance_ip1}],
                                'SetIdentifier': record_id1,
                                'GeoLocation': {
                                    'CountryCode': country_code1,
                                    'SubdivisionCode': subdivision_code1
                                }
                            }
                        }
                    ]
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resource_record_name} com identificador {record_id1} na hosted zone {hosted_zone_name}")
            updated_records = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            existing_records = [record['SetIdentifier'] for record in updated_records['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id1]
            print(f"Identificadores existentes: {existing_records}")

        # SECONDARY INSTANCE
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} com identificador {record_id2} na hosted zone {hosted_zone_name}")

        if any(record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id2 for record in records['ResourceRecordSets']):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {resource_record_name} com identificador {record_id2} na hosted zone {hosted_zone_name}")
            existing_records = [record['SetIdentifier'] for record in records['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id2]
            print(f"Identificadores existentes: {existing_records}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            existing_records = [record['SetIdentifier'] for record in records['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}."]
            print(f"Identificadores: {existing_records}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o IP da instância {tag_name_instance2}")
            instance2 = ec2_client2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance2]}])
            instance_ip2 = instance2['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o registro de nome {resource_record_name} com identificador {record_id2} na hosted zone {hosted_zone_name}")
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
                                'ResourceRecords': [{'Value': instance_ip2}],
                                'SetIdentifier': record_id2,
                                'GeoLocation': {
                                    'CountryCode': country_code2
                                }
                            }
                        }
                    ]
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resource_record_name} com identificador {record_id2} na hosted zone {hosted_zone_name}")
            updated_records = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            existing_records = [record['SetIdentifier'] for record in updated_records['ResourceRecordSets'] if record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id2]
            print(f"Identificadores existentes: {existing_records}")

    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD GEOLOCATION-HOSTED ZONE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"
resource_record_name = "www.pedroheeger.dev.br"
resource_record_type = "A"
ttl = 300
tag_name_instance1 = "ec2Test1"
tag_name_instance2 = "ec2Test2"
record_id1 = "US-NorthVirginia"
record_id2 = "Europe-Paris"
country_code1 = "US"
country_code2 = "FR"
subdivision_code1 = "VA"
region1 = "us-east-1"
region2 = "eu-west-3"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53_client = boto3.client('route53')
    ec2_client1 = boto3.client('ec2', region_name=region1)
    ec2_client2 = boto3.client('ec2', region_name=region2)   

    hosted_zones = route53_client.list_hosted_zones()
    if any(zone['Name'] == hosted_zone_name for zone in hosted_zones['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hosted_zone_id = next(zone['Id'] for zone in hosted_zones['HostedZones'] if zone['Name'] == hosted_zone_name)

        # PRIMARY
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} com identificador {record_id1} na hosted zone {hosted_zone_name}")
        
        records = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
        if any(record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id1 for record in records['ResourceRecordSets']):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            for record in records['ResourceRecordSets']:
                if record['Name'] == f"{resource_record_name}.":
                    print(record['SetIdentifier'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o IP da instância {tag_name_instance1}")
            instance1 = ec2_client1.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance1]}])
            instance_ip1 = instance1['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o registro de nome {resource_record_name} com identificador {record_id1} na hosted zone {hosted_zone_name}")
            route53_client.change_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                ChangeBatch={
                    'Changes': [
                        {
                            'Action': 'DELETE',
                            'ResourceRecordSet': {
                                'Name': resource_record_name,
                                'Type': resource_record_type,
                                'TTL': ttl,
                                'ResourceRecords': [{'Value': instance_ip1}],
                                'SetIdentifier': record_id1,
                                'GeoLocation': {
                                    'CountryCode': country_code1,
                                    'SubdivisionCode': subdivision_code1
                                }
                            }
                        }
                    ]
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            updated_records = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            for record in updated_records['ResourceRecordSets']:
                if record['Name'] == f"{resource_record_name}.":
                    print(record['SetIdentifier'])
        else:
            print(f"Não existe o registro de nome {resource_record_name} com identificador {record_id1} na hosted zone {hosted_zone_name}")

        # SECONDARY
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} com identificador {record_id2} na hosted zone {hosted_zone_name}")
        
        records = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
        if any(record['Name'] == f"{resource_record_name}." and record['SetIdentifier'] == record_id2 for record in records['ResourceRecordSets']):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            for record in records['ResourceRecordSets']:
                if record['Name'] == f"{resource_record_name}.":
                    print(record['SetIdentifier'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o IP da instância {tag_name_instance2}")
            instance2 = ec2_client2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance2]}])
            instance_ip2 = instance2['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o registro de nome {resource_record_name} com identificador {record_id2} na hosted zone {hosted_zone_name}")
            route53_client.change_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                ChangeBatch={
                    'Changes': [
                        {
                            'Action': 'DELETE',
                            'ResourceRecordSet': {
                                'Name': resource_record_name,
                                'Type': resource_record_type,
                                'TTL': ttl,
                                'ResourceRecords': [{'Value': instance_ip2}],
                                'SetIdentifier': record_id2,
                                'GeoLocation': {
                                    'CountryCode': country_code2
                                }
                            }
                        }
                    ]
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            updated_records = route53_client.list_resource_record_sets(HostedZoneId=hosted_zone_id)
            for record in updated_records['ResourceRecordSets']:
                if record['Name'] == f"{resource_record_name}.":
                    print(record['SetIdentifier'])
        else:
            print(f"Não existe o registro de nome {resource_record_name} com identificador {record_id2} na hosted zone {hosted_zone_name}")
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")