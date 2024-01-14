#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "METRIC ALARM DOUBLE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
metricAlarmName1="metricAlarm1"
metricAlarmName2="metricAlarm2"
metricAlarmDescription="metricAlarmDescription"
metricName="CPUUtilization"
namespace="AWS/EC2"
statistic="Average"
threshold1=70
threshold2=40
comparisonOperator1="GreaterThanThreshold"
comparisonOperator2="LessThanThreshold"
asgName="asgTest1"
# assScalingPolicyName="assScalingPolicy1"    # STEP SCALING POLICY
asScalingPolicyName1="asScalingPolicy1"    # SIMPLE SCALING POLICY
asScalingPolicyName2="asScalingPolicy2"    # SIMPLE SCALING POLICY

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
    if [[ $(aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName1' || AlarmName=='$metricAlarmName2'].AlarmName" --output text | wc -l) -gt 1 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe um dos metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName1' || AlarmName=='$metricAlarmName2'].AlarmName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da scaling policy do grupo de auto scaling $asgName"
        # arnScalingPolicy=$(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyARN" --output text)
        arnScalingPolicy1=$(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1'].PolicyARN" --output text)
        arnScalingPolicy2=$(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName2'].PolicyARN" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o metric alarm de nome $metricAlarmName1"
        aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName1 --alarm-description $metricAlarmDescription --metric-name $metricName --namespace $namespace --statistic $statistic --period 300 --threshold $threshold1 --comparison-operator $comparisonOperator1 --unit Percent --evaluation-periods 2 --actions-enabled --dimensions "Name=AutoScalingGroupName,Value=$asgName" --alarm-actions $arnScalingPolicy1

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o metric alarm de nome $metricAlarmName2"
        aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName2 --alarm-description $metricAlarmDescription --metric-name $metricName --namespace $namespace --statistic $statistic --period 300 --threshold $threshold2 --comparison-operator $comparisonOperator2 --unit Percent --evaluation-periods 2 --actions-enabled --dimensions "Name=AutoScalingGroupName,Value=$asgName" --alarm-actions $arnScalingPolicy2

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName1' || AlarmName=='$metricAlarmName2'].AlarmName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "METRIC ALARM DOUBLE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
metricAlarmName1="metricAlarm1"
metricAlarmName2="metricAlarm2"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
    if [[ $(aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName1' || AlarmName=='$metricAlarmName2'].AlarmName" --output text | wc -l) -gt 1 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
        aws cloudwatch delete-alarms --alarm-names $metricAlarmName1 $metricAlarmName2

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text
    else
        echo "Não existe um dos metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
    fi
else
    echo "Código não executado"
fi