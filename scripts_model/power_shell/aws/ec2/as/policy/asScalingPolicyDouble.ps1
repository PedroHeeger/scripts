#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "SIMPLE SCALING POLICY DOBULE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asScalingPolicyName1 = "asScalingPolicy1"
$asScalingPolicyName2 = "asScalingPolicy2"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a simple scaling policy de nome $asScalingPolicyName1 no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $asScalingPolicyName1 --auto-scaling-group-name $asgName --policy-type SimpleScaling --scaling-adjustment 1 --adjustment-type "ChangeInCapacity" --cooldown 300

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a simple scaling policy de nome $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $asScalingPolicyName2 --auto-scaling-group-name $asgName --policy-type SimpleScaling --scaling-adjustment -1 --adjustment-type "ChangeInCapacity" --cooldown 300

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "SIMPLE SCALING POLICY DOUBLE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asScalingPolicyName1 = "asScalingPolicy1"
$asScalingPolicyName2 = "asScalingPolicy2"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo as simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $asScalingPolicyName1
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $asScalingPolicyName2

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text
    } else {Write-Output "Não existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"}
} else {Write-Host "Código não executado"}