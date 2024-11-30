import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("METRIC ALARM HEALTH CHECK CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
metric_alarm_name = "healthCheckMetricAlarm1"
metric_alarm_description = "metricAlarmDescription1"
metric_name = "HealthCheckStatus"
namespace = "AWS/Route53"
statistic = "Average"  # Se a média dos resultados da métrica em apenas 1 período no intervalo de tempo de 60 segundos for menor que o limite de 1, o alarme é acionado
period = 60
threshold = 1
comparison_operator = "LessThanThreshold"
evaluation_periods = 1

resource_key = "HealthCheckId"
# health_check_name = "healthCheckTest1"
health_check_name = "terraform-20241130174808043600000001"
topic_name = "snsTopicTest1"
region = "us-east-1"
account_id = "001727357081"
topic_arn = f"arn:aws:sns:{region}:{account_id}:{topic_name}"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a verificação de integridade {health_check_name} e o tópico {topic_name}")
    route53_client = boto3.client('route53', region_name=region)
    sns_client = boto3.client('sns', region_name=region)

    health_checks = route53_client.list_health_checks()
    health_check_exists = any(
        hc['CallerReference'] == health_check_name for hc in health_checks['HealthChecks']
    )

    sns_topics = sns_client.list_topics()
    topic_exists = any(
        topic['TopicArn'] == topic_arn for topic in sns_topics['Topics']
    )

    condition = health_check_exists and topic_exists
    if condition:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o metric alarm de nome {metric_alarm_name}")
        cloudwatch = boto3.client('cloudwatch', region_name=region)
        route53 = boto3.client('route53', region_name=region)

        alarms = cloudwatch.describe_alarms(AlarmNames=[metric_alarm_name])
        alarm_names = [alarm['AlarmName'] for alarm in alarms['MetricAlarms']]
        if metric_alarm_name in alarm_names:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o metric alarm de nome {metric_alarm_name}")
            print(metric_alarm_name)
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando todos os metric alarms existentes")
            alarms = cloudwatch.describe_alarms()
            all_alarm_names = [alarm['AlarmName'] for alarm in alarms['MetricAlarms']]
            for name in all_alarm_names:
                print(name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ID da verificação de integridade de nome {health_check_name}")
            health_checks = route53.list_health_checks()
            health_check_id = next(
                (hc['Id'] for hc in health_checks['HealthChecks'] if hc['CallerReference'] == health_check_name), 
                None
            )

            if health_check_id:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Criando o metric alarm de nome {metric_alarm_name}")
                cloudwatch.put_metric_alarm(
                    AlarmName=metric_alarm_name,
                    AlarmDescription=metric_alarm_description,
                    MetricName=metric_name,
                    Namespace=namespace,
                    Statistic=statistic,
                    Period=period,
                    Threshold=threshold,
                    ComparisonOperator=comparison_operator,
                    EvaluationPeriods=evaluation_periods,
                    Dimensions=[{
                        'Name': resource_key,
                        'Value': health_check_id
                    }],
                    AlarmActions=[topic_arn],
                    OKActions=[topic_arn]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o metric alarm de nome {metric_alarm_name}")
                alarms = cloudwatch.describe_alarms(AlarmNames=[metric_alarm_name])
                alarm_names = [alarm['AlarmName'] for alarm in alarms['MetricAlarms']]
                for metric_alarm_name in alarm_names:
                    print(metric_alarm_name)
            else:
                print(f"Não foi possível encontrar o HealthCheckId para o nome {health_check_name}")
    else:
        print(f"Não existe a verificação de integridade {health_check_name} ou o tópico {topic_name}")            
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON CLOUDWATCH")
print("METRIC ALARM HEALTH CHECK EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
metric_alarm_name = "healthCheckMetricAlarm1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o metric alarm de nome {metric_alarm_name}")
    cloudwatch = boto3.client('cloudwatch', region_name='us-east-1')

    alarms = cloudwatch.describe_alarms(AlarmNames=[metric_alarm_name])
    alarm_names = [alarm['AlarmName'] for alarm in alarms['MetricAlarms']]
    if metric_alarm_name in alarm_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os metric alarms existentes")
        alarms = cloudwatch.describe_alarms()
        all_alarm_names = [alarm['AlarmName'] for alarm in alarms['MetricAlarms']]
        for name in all_alarm_names:
            print(name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o metric alarm de nome {metric_alarm_name}")
        cloudwatch.delete_alarms(AlarmNames=[metric_alarm_name])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os metric alarms existentes")
        alarms = cloudwatch.describe_alarms()
        all_alarm_names = [alarm['AlarmName'] for alarm in alarms['MetricAlarms']]
        for name in all_alarm_names:
            print(name)
    else:
        print(f"Não existe o metric alarm de nome {metric_alarm_name}")
else:
    print("Código não executado")