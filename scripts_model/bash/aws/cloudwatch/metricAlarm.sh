#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "METRIC ALARM CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
metricAlarmName="metricAlarm1"
metricAlarmDescription="metricAlarmDescription1"
metricName="CPUUtilization"
namespace="AWS/EC2"
statistic="Average"
threshold=70
comparisonOperator="GreaterThanThreshold"
asgName="asgTest1"
asScalingPolicyName="asScalingPolicy1"    # SIMPLE SCALING POLICY
# asScalingPolicyName="assScalingPolicy1"    # STEP SCALING POLICY

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o metric alarm de nome $metricAlarmName"
    if [[ $(aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o metric alarm de nome $metricAlarmName"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da scaling policy simples do grupo de auto scaling $asgName"
        arnScalingPolicy=$(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyARN" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o metric alarm de nome $metricAlarmName"
        aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName --alarm-description "$metricAlarmDescription" --metric-name $metricName --namespace $namespace --statistic $statistic --period 300 --threshold $threshold --comparison-operator $comparisonOperator --dimensions "Name=AutoScalingGroupName,Value=$asgName" --evaluation-periods 2 --alarm-actions $arnScalingPolicy

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o metric alarm de nome $metricAlarmName"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "METRIC ALARM EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
metricAlarmName="metricAlarm1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o metric alarm de nome $metricAlarmName"
    if [[ $(aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text | wc -l) -gt 0 ]]; then
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