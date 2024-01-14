#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "METRIC ALARM DOUBLE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$metricAlarmName1 = "metricAlarm1"
$metricAlarmName2 = "metricAlarm2"
$metricAlarmDescription = "metricAlarmDescription"
$metricName = "CPUUtilization"
$namespace = "AWS/EC2"
$statistic = "Average"
$threshold1 = 70
$threshold2 = 40
$comparisonOperator1 = "GreaterThanThreshold"
$comparisonOperator2 = "LessThanThreshold"
$asgName = "asgTest1"
# $assScalingPolicyName = "assScalingPolicy1"    # STEP SCALING POLICY
$asScalingPolicyName1 = "asScalingPolicy1"    # SIMPLE SCALING POLICY
$asScalingPolicyName2 = "asScalingPolicy2"    # SIMPLE SCALING POLICY

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
    if ((aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName1' || AlarmName=='$metricAlarmName2'].AlarmName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe um dos metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName' || AlarmName=='$metricAlarmName2'].AlarmName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN da scaling policy do grupo de auto scaling $asgName"
        # $arnScalingPolicy = aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyARN" --output text
        $arnScalingPolicy1 = aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1'].PolicyARN" --output text
        $arnScalingPolicy2 = aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName2'].PolicyARN" --output text

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando o metric alarm de nome $metricAlarmName1"
        # aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName1 --alarm-description $metricAlarmDescription --metric-name $metricName --namespace $namespace --statistic $statistic --period 300 --threshold $threshold1 --comparison-operator $comparisonOperator1 --unit Percent --evaluation-periods 2 --actions-enabled --dimensions "Name=AutoScalingGroupName,Value=$asgName" --alarm-actions $arnScalingPolicy
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o metric alarm de nome $metricAlarmName1"
        aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName1 --alarm-description $metricAlarmDescription --metric-name $metricName --namespace $namespace --statistic $statistic --period 300 --threshold $threshold1 --comparison-operator $comparisonOperator1 --unit Percent --evaluation-periods 2 --actions-enabled --dimensions "Name=AutoScalingGroupName,Value=$asgName" --alarm-actions $arnScalingPolicy1

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o metric alarm de nome $metricAlarmName2"
        aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName2 --alarm-description $metricAlarmDescription --metric-name $metricName --namespace $namespace --statistic $statistic --period 300 --threshold $threshold2 --comparison-operator $comparisonOperator2 --unit Percent --evaluation-periods 2 --actions-enabled --dimensions "Name=AutoScalingGroupName,Value=$asgName" --alarm-actions $arnScalingPolicy2

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName1' || AlarmName=='$metricAlarmName2'].AlarmName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "METRIC ALARM DOUBLE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$metricAlarmName1 = "metricAlarm1"
$metricAlarmName2 = "metricAlarm2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
    if ((aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName1' || AlarmName=='$metricAlarmName2'].AlarmName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo os metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"
        aws cloudwatch delete-alarms --alarm-names $metricAlarmName1 $metricAlarmName2

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text
    } else {Write-Output "Não existe um dos metric alarms de nomes $metricAlarmName1 e $metricAlarmName2"}
} else {Write-Host "Código não executado"}