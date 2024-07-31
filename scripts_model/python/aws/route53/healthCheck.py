import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("HEALTH CHECK CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hosted_zone_name = "pedroheeger.dev.br."
health_check_name = "healthCheckTest8"
ip_address = "175.184.182.193"
port_number = 80
type_protocol = "HTTP"
resource_path = "/"
request_interval = 30      # Faz uma requisição para a instância a cada 30 segundos e considera a instância como não saudável se receber 3 falhas consecutivas.
failure_threshold = 3
tag_name_instance = "ec2Test1"
tag_health_check = health_check_name

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    hosted_zones = client.list_hosted_zones_by_name(DNSName=hosted_zone_name)['HostedZones']
    if len(hosted_zones) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a verificação de integridade de nome {health_check_name}")
        health_checks = client.list_health_checks()['HealthChecks']
        health_check_exists = any(hc['CallerReference'] == health_check_name for hc in health_checks)
        if health_check_exists:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe a verificação de integridade de nome {health_check_name}")
            for hc in health_checks:
                if hc['CallerReference'] == health_check_name:
                    print(hc['CallerReference'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todas as verificações de integridade criadas")
            for hc in health_checks:
                print(hc['CallerReference'])

            ec2_client = boto3.client('ec2')

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o IP da instância {tag_name_instance}")
            instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}])
            if instances['Reservations'] and instances['Reservations'][0]['Instances']:
                instanceIP = instances['Reservations'][0]['Instances'][0].get('PublicIpAddress', None)
            else:
                instanceIP = None
            # ip_address = instanceIP

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando a verificação de integridade de nome {health_check_name}")
            response = client.create_health_check(
                CallerReference=health_check_name,
                HealthCheckConfig={
                    'IPAddress': ip_address,
                    'Port': port_number,
                    'Type': type_protocol,
                    'ResourcePath': resource_path,
                    'RequestInterval': request_interval,
                    'FailureThreshold': failure_threshold,
                    'EnableSNI': False
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ID da verificação de integridade de nome {health_check_name}")
            health_check_id = response['HealthCheck']['Id']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Adicionando uma tag de nome para a verificação de integridade de nome {health_check_name}")
            client.change_tags_for_resource(
                ResourceType='healthcheck',
                ResourceId=health_check_id,
                AddTags=[
                    {
                        'Key': 'Name',
                        'Value': tag_health_check
                    }
                ]
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a verificação de integridade de nome {health_check_name}")
            health_checks = client.list_health_checks()['HealthChecks']
            for hc in health_checks:
                if hc['CallerReference'] == health_check_name:
                    print(hc['CallerReference'])
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("HEALTH CHECK EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
hosted_zone_name = "pedroheeger.dev.br."
health_check_name = "healthCheckTest8"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Route53")
    client = boto3.client('route53')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    hosted_zones = client.list_hosted_zones_by_name(DNSName=hosted_zone_name)['HostedZones']
    if len(hosted_zones) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a verificação de integridade de nome {health_check_name}")
        health_checks = client.list_health_checks()['HealthChecks']
        health_check_exists = any(hc['CallerReference'] == health_check_name for hc in health_checks)
        if health_check_exists:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todas as verificações de integridade criadas")
            for hc in health_checks:
                print(hc['CallerReference'])

            print("Extraindo o ID da verificação de integridade de nome {health_check_name}")
            healthCheckId = next(hc['Id'] for hc in health_checks if hc['CallerReference'] == health_check_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a verificação de integridade de nome {health_check_name}")
            client.delete_health_check(HealthCheckId=healthCheckId)

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todas as verificações de integridade criadas")
            health_checks = client.list_health_checks()['HealthChecks']
            for hc in health_checks:
                print(hc['CallerReference'])
        else:
            print(f"Não existe a verificação de integridade de nome {health_check_name}")
    else:
        print(f"Não existe a hosted zone de nome {hosted_zone_name}")
else:
    print("Código não executado")