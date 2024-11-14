import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("HEALTH CHECK CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# domain_name = "hosted-zone-test1.com.br"  # Um domínio é o nome de um site ou serviço na internet
domain_name = "pedroheeger.dev.br"
hosted_zone_name = domain_name + "."  # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
health_check_name = "healthCheckTest3"
tag_health_check = health_check_name
tag_name_instance = "ec2Test1"
ip_address = "175.184.182.193"
port_number = 80
type_protocol = "HTTP"
resource_path = "/"
request_interval = 30      # Faz uma requisição para a instância a cada 30 segundos e considera a instância como não saudável se receber 3 falhas consecutivas.
failure_threshold = 3

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53 = boto3.client('route53')
    response = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')
    
    if any(zone['Name'] == hosted_zone_name for zone in response['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a verificação de integridade {health_check_name}")
        health_checks = route53.list_health_checks()['HealthChecks']
        health_check_exists = any(hc['CallerReference'] == health_check_name for hc in health_checks)
        if health_check_exists:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe a verificação de integridade {health_check_name}")
            for hc in health_checks:
                if hc['CallerReference'] == health_check_name:
                    print(hc['CallerReference'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todas as verificações de integridade criadas")
            for hc in health_checks:
                print(hc['CallerReference'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe uma instância ativa {tag_name_instance}")
            ec2_client = boto3.client('ec2')
            condition = ec2_client.describe_instances(
                Filters=[
                    {'Name': 'tag:Name', 'Values': [tag_name_instance]},
                    {'Name': 'instance-state-name', 'Values': ['running']}
                ]
            )
            
            if len(condition['Reservations']) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o IP da instância {tag_name_instance}")
                instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}])
                if instances['Reservations'] and instances['Reservations'][0]['Instances']:
                    instanceIP = instances['Reservations'][0]['Instances'][0].get('PublicIpAddress', None)
                    ip_address = instanceIP                
            else:
                print(f"Não existe uma instância ativa {tag_name_instance}. Será utilizado o endereço de IP indicado.")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando a verificação de integridade {health_check_name}")
            response = route53.create_health_check(
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
            print(f"Extraindo o ID da verificação de integridade {health_check_name}")
            health_check_id = response['HealthCheck']['Id']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Adicionando uma tag para a verificação de integridade {health_check_name}")
            route53.change_tags_for_resource(
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
            print(f"Listando a verificação de integridade {health_check_name}")
            health_checks = route53.list_health_checks()['HealthChecks']
            for hc in health_checks:
                if hc['CallerReference'] == health_check_name:
                    print(hc['CallerReference'])
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON ROUTE 53")
print("HEALTH CHECK EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# domain_name = "hosted-zone-test1.com.br"  # Um domínio é o nome de um site ou serviço na internet
domain_name = "pedroheeger.dev.br"
hosted_zone_name = domain_name + "."  # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
health_check_name = "healthCheckTest3"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a hosted zone {hosted_zone_name}")
    route53 = boto3.client('route53')
    response = route53.list_hosted_zones_by_name(DNSName=hosted_zone_name, MaxItems='1')
    
    if any(zone['Name'] == hosted_zone_name for zone in response['HostedZones']):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a verificação de integridade {health_check_name}")
        health_checks = route53.list_health_checks()['HealthChecks']
        health_check_exists = any(hc['CallerReference'] == health_check_name for hc in health_checks)
        if health_check_exists:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todas as verificações de integridade criadas")
            for hc in health_checks:
                print(hc['CallerReference'])

            print("Extraindo o ID da verificação de integridade {health_check_name}")
            healthCheckId = next(hc['Id'] for hc in health_checks if hc['CallerReference'] == health_check_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a verificação de integridade {health_check_name}")
            route53.delete_health_check(HealthCheckId=healthCheckId)

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todas as verificações de integridade criadas")
            health_checks = route53.list_health_checks()['HealthChecks']
            for hc in health_checks:
                print(hc['CallerReference'])
        else:
            print(f"Não existe a verificação de integridade {health_check_name}")
    else:
        print(f"Não existe a hosted zone {hosted_zone_name}")
else:
    print("Código não executado")