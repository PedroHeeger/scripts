#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "METRIC ALARM HEALTH CHECK CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
metricAlarmName="healthCheckMetricAlarm1"
metricAlarmDescription="metricAlarmDescription1"
metricName="HealthCheckStatus"
namespace="AWS/Route53"
statistic="Average"           # Se a média dos resultados da métrica em apenas 1 período no intervalo de tempo de 60 segundos for menor que o limite de 1, o alarme é acionado
period=60
threshold=1
comparisonOperator="LessThanThreshold"
evaluationPeriods=1

resourceKey="HealthCheckId"
healthCheckName="healthCheckTest1"
# healthCheckName="terraform-20241130174808043600000001"
topicName="snsTopicTest1"
region="us-east-1"
accountId="001727357081"
topicArn="arn:aws:sns:${region}:${accountId}:${topicName}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a verificação de integridade $healthCheckName e o tópico $topicName"
    healthCheck=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text)
    topic=$(aws sns list-topics --query "Topics[?TopicArn=='$topicArn'].TopicArn" --output text)
    if [[ -n "$healthCheck" && -n "$topic" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o metric alarm de nome $metricAlarmName"
        condition=$(aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text | wc -l)
        if [[ $condition -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o metric alarm de nome $metricAlarmName"
            aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os metric alarms existentes"
            aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID da verificação de integridade de nome $healthCheckName"
            healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o metric alarm de nome $metricAlarmName"
            aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName --alarm-description "$metricAlarmDescription" --metric-name $metricName --namespace $namespace --statistic $statistic --period $period --threshold $threshold --comparison-operator $comparisonOperator --evaluation-periods $evaluationPeriods --dimensions "Name=$resourceKey,Value=$healthCheckId" --alarm-actions $topicArn --ok-actions $topicArn

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o metric alarm de nome $metricAlarmName"
            aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text
        fi
    else
        echo "Não existe a verificação de integridade $healthCheckName ou o tópico $topicName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "METRIC ALARM HEALTH CHECK EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
metricAlarmName="healthCheckMetricAlarm1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o metric alarm de nome $metricAlarmName"
    condition=$(aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text | wc -l)
    if [[ $condition -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o metric alarm de nome $metricAlarmName"
        aws cloudwatch delete-alarms --alarm-names $metricAlarmName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text
    else
        echo "Não existe o metric alarm de nome $metricAlarmName"
    fi
else
    echo "Código não executado"
fi