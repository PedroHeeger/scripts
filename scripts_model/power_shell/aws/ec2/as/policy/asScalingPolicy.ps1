#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "SIMPLE SCALING POLICY CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asScalingPolicyName = "asScalingPolicy1"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a simple scaling policy de nome $asScalingPolicyName1 no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $asScalingPolicyName1 --auto-scaling-group-name $asgName --policy-type SimpleScaling --scaling-adjustment 1 --adjustment-type "ChangeInCapacity" --cooldown 300

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "SIMPLE SCALING POLICY EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asScalingPolicyName = "asScalingPolicy1"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os auto scaling groups existentes"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[].PolicyName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $asScalingPolicyName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os auto scaling groups existentes"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[].PolicyName" --output text
    } else {Write-Output "Não existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"}
} else {Write-Host "Código não executado"}