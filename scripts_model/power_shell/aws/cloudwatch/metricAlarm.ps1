#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "METRIC ALARM CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$metricAlarmName = "metricAlarm1"
$metricAlarmDescription = "metricAlarmDescription1"
$metricName = "CPUUtilization"
$namespace = "AWS/EC2"
$statistic = "Average"
$threshold = 70
$comparisonOperator = "GreaterThanThreshold"
$asgName = "asgTest1"
$asScalingPolicyName = "asScalingPolicy1"    # SIMPLE SCALING POLICY
# $asScalingPolicyName = "assScalingPolicy1"    # STEP SCALING POLICY

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o metric alarm de nome $metricAlarmName"
    if ((aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o metric alarm de nome $metricAlarmName"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN da scaling policy simples do grupo de auto scaling $asgName"
        $arnScalingPolicy = aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyARN" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o metric alarm de nome $metricAlarmName"
        aws cloudwatch put-metric-alarm --alarm-name $metricAlarmName --alarm-description $metricAlarmDescription --metric-name $metricName --namespace $namespace --statistic $statistic --period 300 --threshold $threshold --comparison-operator $comparisonOperator --dimensions "Name=AutoScalingGroupName,Value=$asgName" --evaluation-periods 2 --alarm-actions $arnScalingPolicy

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o metric alarm de nome $metricAlarmName"
        aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "METRIC ALARM EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$metricAlarmName = "metricAlarm1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o metric alarm de nome $metricAlarmName"
    if ((aws cloudwatch describe-alarms --query "MetricAlarms[?AlarmName=='$metricAlarmName'].AlarmName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o metric alarm de nome $metricAlarmName"
        aws cloudwatch delete-alarms --alarm-names $metricAlarmName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os metric alarms existentes"
        aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text
    } else {Write-Output "Não existe o metric alarm de nome $metricAlarmName"}
} else {Write-Host "Código não executado"}