import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD FAILOVER-HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hostedZoneName = "pedroheeger.dev.br."
domainName = "pedroheeger.dev.br"
resourceRecordName = "www.pedroheeger.dev.br"
resourceRecordType = "A"
ttl = 300
tagNameInstance1 = "ec2Test1"
tagNameInstance2 = "ec2Test2"
failoverRecordType1 = "PRIMARY"   # PRIMARY OR SECONDARY
failoverRecordType2 = "SECONDARY"   # PRIMARY OR SECONDARY
healthCheckName = "healthCheckTest5"
recordId1 = "Primary"
recordId2 = "Secondary"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hostedZoneName}")
    response = client.list_hosted_zones_by_name(DNSName=hostedZoneName)
    if len(response['HostedZones']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hostedZoneName}")
        hostedZoneId = response['HostedZones'][0]['Id'].split('/')[-1]

        # PRIMARY INSTANCE
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resourceRecordName} com identificador {recordId1} na hosted zone {hostedZoneName}")
        response = client.list_resource_record_sets(
            HostedZoneId=hostedZoneId,
            StartRecordName=resourceRecordName,
            StartRecordType=resourceRecordType,
            StartRecordIdentifier=recordId1,
            MaxItems='1'
        )

        if len(response['ResourceRecordSets']) > 0 and response['ResourceRecordSets'][0]['Name'] == f"{resourceRecordName}." and response['ResourceRecordSets'][0]['SetIdentifier'] == recordId1:
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {resourceRecordName} com identificador {recordId1} na hosted zone {hostedZoneName}")
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}." and record_set.get('SetIdentifier') == recordId1:
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resourceRecordName} na hosted zone {hostedZoneName}")
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resourceRecordName)
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}.":
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")


            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o IP da instância {tagNameInstance1}")
            ec2_client = boto3.client('ec2')
            instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tagNameInstance1]}])
            instanceIP1 = instances['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("Extraindo o ID da verificação de integridade de nome", healthCheckName)
            health_checks = client.list_health_checks()
            health_check_id = None
            for check in health_checks['HealthChecks']:
                if check['CallerReference'] == healthCheckName:
                    health_check_id = check['Id']
                    break

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o registro de nome {resourceRecordName} com identificador {recordId1} na hosted zone {hostedZoneName}")
            change_batch = {
                "Changes": [
                    {
                        "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": resourceRecordName,
                            "Type": resourceRecordType,
                            "TTL": ttl,
                            "ResourceRecords": [{"Value": instanceIP1}],
                            "SetIdentifier": recordId1,
                            "Failover": failoverRecordType1,
                            "HealthCheckId": health_check_id
                        }
                    }
                ]
            }
            client.change_resource_record_sets(HostedZoneId=hostedZoneId, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resourceRecordName} com identificador {recordId1} na hosted zone {hostedZoneName}")
            response = client.list_resource_record_sets(
                HostedZoneId=hostedZoneId,
                StartRecordName=resourceRecordName,
                StartRecordType=resourceRecordType,
                StartRecordIdentifier=recordId1,
                MaxItems='1'
            )
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}." and record_set.get('SetIdentifier') == recordId1:
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")                  


        # SECONDARY INSTANCE
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resourceRecordName} com identificador {recordId2} na hosted zone {hostedZoneName}")
        response = client.list_resource_record_sets(
            HostedZoneId=hostedZoneId,
            StartRecordName=resourceRecordName,
            StartRecordType=resourceRecordType,
            StartRecordIdentifier=recordId2,
            MaxItems='1'
        )

        if len(response['ResourceRecordSets']) > 0 and response['ResourceRecordSets'][0]['Name'] == f"{resourceRecordName}." and response['ResourceRecordSets'][0]['SetIdentifier'] == recordId2:
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {resourceRecordName} com identificador {recordId2} na hosted zone {hostedZoneName}")
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}." and record_set.get('SetIdentifier') == recordId2:
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resourceRecordName} na hosted zone {hostedZoneName}")
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resourceRecordName)
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}.":
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o IP da instância {tagNameInstance2}")
            ec2_client = boto3.client('ec2')
            instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tagNameInstance2]}])
            instanceIP2 = instances['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o registro de nome {resourceRecordName} com identificador {recordId2} na hosted zone {hostedZoneName}")
            change_batch = {
                "Changes": [
                    {
                        "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": resourceRecordName,
                            "Type": resourceRecordType,
                            "TTL": ttl,
                            "ResourceRecords": [{"Value": instanceIP2}],
                            "SetIdentifier": recordId2,
                            "Failover": failoverRecordType2
                        }
                    }
                ]
            }
            client.change_resource_record_sets(HostedZoneId=hostedZoneId, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resourceRecordName} com identificador {recordId2} na hosted zone {hostedZoneName}")         
            response = client.list_resource_record_sets(
                HostedZoneId=hostedZoneId,
                StartRecordName=resourceRecordName,
                StartRecordType=resourceRecordType,
                StartRecordIdentifier=recordId2,
                MaxItems='1'
            )
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}." and record_set.get('SetIdentifier') == recordId2:
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")
    else:
        print(f"Não existe a hosted zone de nome {hostedZoneName}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD FAILOVER-HOSTED ZONE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hostedZoneName = "pedroheeger.dev.br."
domainName = "pedroheeger.dev.br"
resourceRecordName = "www.pedroheeger.dev.br"
resourceRecordType = "A"
ttl = 300
tagNameInstance1 = "ec2Test1"
tagNameInstance2 = "ec2Test2"
failoverRecordType1 = "PRIMARY"   # PRIMARY OR SECONDARY
failoverRecordType2 = "SECONDARY"   # PRIMARY OR SECONDARY
healthCheckName = "healthCheckTest5"
recordId1 = "Primary"
recordId2 = "Secondary"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hostedZoneName}")
    response = client.list_hosted_zones_by_name(DNSName=hostedZoneName)
    if len(response['HostedZones']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hostedZoneName}")
        hostedZoneId = response['HostedZones'][0]['Id'].split('/')[-1]

        # PRIMARY INSTANCE
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resourceRecordName} com identificador {recordId1} na hosted zone {hostedZoneName}")
        response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resourceRecordName)

        if response['ResourceRecordSets']:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resourceRecordName} na hosted zone {hostedZoneName}")
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}.":
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se o IP está vazio, caso esteja extraindo o IP da instância {tagNameInstance1} configurado no registro de nome {resourceRecordName}")
            instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tagNameInstance1]}])
            if instances['Reservations'] and instances['Reservations'][0]['Instances']:
                instanceIP1 = instances['Reservations'][0]['Instances'][0].get('PublicIpAddress', None)
            else:
                response = boto3.client('route53').list_resource_record_sets(
                    HostedZoneId=hostedZoneId,
                    QueryString=f"ResourceRecordSets[?Name=='{resourceRecordName}.'][?SetIdentifier=='{recordId1}'].ResourceRecords[].Value"
                )
                records = response['ResourceRecordSets']
                if records:
                    instanceIP1 = records[0]['ResourceRecords'][0]['Value']

            # print("-----//-----//-----//-----//-----//-----//-----")
            # print(f"Extraindo o IP da instância {tagNameInstance1}")
            # ec2_client = boto3.client('ec2')
            # instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tagNameInstance1]}])
            # instanceIP1 = instances['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("Extraindo o ID da verificação de integridade de nome", healthCheckName)
            health_checks = client.list_health_checks()
            health_check_id = None
            for check in health_checks['HealthChecks']:
                if check['CallerReference'] == healthCheckName:
                    health_check_id = check['Id']
                    break

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o registro de nome {resourceRecordName} com identificador {recordId1} na hosted zone {hostedZoneName}")
            client.change_resource_record_sets(
                HostedZoneId=hostedZoneId,
                ChangeBatch={
                    'Changes': [
                        {
                            'Action': 'DELETE',
                            'ResourceRecordSet': {
                                'Name': resourceRecordName,
                                'Type': resourceRecordType,
                                'TTL': ttl,
                                'ResourceRecords': [
                                    {'Value': instanceIP1}
                                ],
                                'SetIdentifier': recordId1,
                                'Failover': failoverRecordType1,
                                'HealthCheckId': health_check_id
                            }
                        }
                    ]
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resourceRecordName} na hosted zone {hostedZoneName}")
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resourceRecordName)
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}.":
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")
        else:
            print(f"Não existe o registro de nome {resourceRecordName} com identificador {recordId1} na hosted zone {hostedZoneName}")


        # SECONDARY INSTANCE
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resourceRecordName} com identificador {recordId2} na hosted zone {hostedZoneName}")
        response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resourceRecordName)

        if response['ResourceRecordSets']:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resourceRecordName} na hosted zone {hostedZoneName}")
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}.":
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se o IP está vazio, caso esteja extraindo o IP da instância {tagNameInstance2} configurado no registro de nome {resourceRecordName}")
            instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tagNameInstance2]}])
            if instances['Reservations'] and instances['Reservations'][0]['Instances']:
                instanceIP2 = instances['Reservations'][0]['Instances'][0].get('PublicIpAddress', None)
            else:
                response = boto3.client('route53').list_resource_record_sets(
                    HostedZoneId=hostedZoneId,
                    QueryString=f"ResourceRecordSets[?Name=='{resourceRecordName}.'][?SetIdentifier=='{recordId2}'].ResourceRecords[].Value"
                )
                records = response['ResourceRecordSets']
                if records:
                    instanceIP2 = records[0]['ResourceRecords'][0]['Value']

            # print("-----//-----//-----//-----//-----//-----//-----")
            # print(f"Extraindo o IP da instância {tagNameInstance2}")
            # instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tagNameInstance2]}])
            # instanceIP2 = instances['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o registro de nome {resourceRecordName} com identificador {recordId2} na hosted zone {hostedZoneName}")
            client.change_resource_record_sets(
                HostedZoneId=hostedZoneId,
                ChangeBatch={
                    'Changes': [
                        {
                            'Action': 'DELETE',
                            'ResourceRecordSet': {
                                'Name': resourceRecordName,
                                'Type': resourceRecordType,
                                'TTL': ttl,
                                'ResourceRecords': [
                                    {'Value': instanceIP2}
                                ],
                                'SetIdentifier': recordId2,
                                'Failover': failoverRecordType2
                            }
                        }
                    ]
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros de nome {resourceRecordName} na hosted zone {hostedZoneName}") 
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resourceRecordName)
            for record_set in response['ResourceRecordSets']:
                if record_set['Name'] == f"{resourceRecordName}.":
                    print(f"Nome: {record_set['Name']} / Identificador: {record_set.get('SetIdentifier', 'N/A')}")  
        else:
            print(f"Não existe o registro de nome {resourceRecordName} com identificador {recordId2} na hosted zone {hostedZoneName}")
    else:
        print(f"Não existe a hosted zone de nome {hostedZoneName}")
else:
    print("Código não executado")