#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "STEP SCALING POLICY CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$assScalingPolicyName = "assScalingPolicy1"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as step scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='StepScaling'].PolicyName[]" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $assScalingPolicyName --auto-scaling-group-name $asgName --policy-type StepScaling --adjustment-type "ChangeInCapacity" --cooldown 300 --step-adjustments "[
            {
                `"MetricIntervalLowerBound`": 0.0, 
                `"MetricIntervalUpperBound`": 40.0, 
                `"ScalingAdjustment`": 0
            }, {
                `"MetricIntervalLowerBound`": 40.0, 
                `"MetricIntervalUpperBound`": 90.0, 
                `"ScalingAdjustment`": 1
            }, {
                `"MetricIntervalLowerBound`": 90.0,
                `"ScalingAdjustment`": 2
            }]"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "STEP SCALING POLICY EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$assScalingPolicyName = "assScalingPolicy1"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as step scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='StepScaling'].PolicyName[]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $assScalingPolicyName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as step scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='StepScaling'].PolicyName[]" --output text
    } else {Write-Output "Não existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"}
} else {Write-Host "Código não executado"}