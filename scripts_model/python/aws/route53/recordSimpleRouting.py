import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD SIMPLE ROUTING-HOSTED ZONE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"
resource_record_name = "www.pedroheeger.dev.br"
resource_record_type = "A"
ttl = 300
tag_name_instance = "ec2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    response = client.list_hosted_zones_by_name(DNSName=hosted_zone_name)
    if len(response['HostedZones']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hostedZoneId = response['HostedZones'][0]['Id'].split('/')[-1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o IP público da instância {tag_name_instance}")
        ec2_client = boto3.client('ec2')
        instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}])
        instanceIP = instances['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
        response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resource_record_name, MaxItems='1')
        if len(response['ResourceRecordSets']) > 0 and response['ResourceRecordSets'][0]['Name'] == f"{resource_record_name}.":
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            print(response['ResourceRecordSets'][0]['Name'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            change_batch = {
                "Changes": [
                    {
                        "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": resource_record_name,
                            "Type": resource_record_type,
                            "TTL": ttl,
                            "ResourceRecords": [{"Value": instanceIP}]
                        }
                    }
                ]
            }
            client.change_resource_record_sets(HostedZoneId=hostedZoneId, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resource_record_name, MaxItems='1')
            print(response['ResourceRecordSets'][0]['Name'])
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("RECORD SIMPLE ROUTING-HOSTED ZONE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hosted_zone_name = "pedroheeger.dev.br."
domain_name = "pedroheeger.dev.br"
resource_record_name = "www.pedroheeger.dev.br"
resource_record_type = "A"
ttl = 300
tag_name_instance = "ec2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    response = client.list_hosted_zones_by_name(DNSName=hosted_zone_name)
    if len(response['HostedZones']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da hosted zone {hosted_zone_name}")
        hostedZoneId = response['HostedZones'][0]['Id'].split('/')[-1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o IP público da instância {tag_name_instance}")
        ec2_client = boto3.client('ec2')
        instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}])
        instanceIP = instances['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
        response = client.list_resource_record_sets(HostedZoneId=hostedZoneId, StartRecordName=resource_record_name, MaxItems='1')
        if len(response['ResourceRecordSets']) > 0 and response['ResourceRecordSets'][0]['Name'] == f"{resource_record_name}.":
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId)
            for record_set in response['ResourceRecordSets']:
                print(record_set['Name'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
            change_batch = {
                "Changes": [
                    {
                        "Action": "DELETE",
                        "ResourceRecordSet": {
                            "Name": resource_record_name,
                            "Type": resource_record_type,
                            "TTL": ttl,
                            "ResourceRecords": [{"Value": instanceIP}]
                        }
                    }
                ]
            }
            client.change_resource_record_sets(HostedZoneId=hostedZoneId, ChangeBatch=change_batch)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os registros da hosted zone {hosted_zone_name}")
            response = client.list_resource_record_sets(HostedZoneId=hostedZoneId)
            for record_set in response['ResourceRecordSets']:
                print(record_set['Name'])

        else:
            print(f"Não existe o registro de nome {resource_record_name} na hosted zone {hosted_zone_name}")
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")