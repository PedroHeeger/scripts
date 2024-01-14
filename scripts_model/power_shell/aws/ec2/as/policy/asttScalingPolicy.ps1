#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "TARGET TRACKING SCALING POLICY CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asttScalingPolicyName = "asttScalingPolicy1"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asttScalingPolicyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asttScalingPolicyName'].PolicyName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as target tracking scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='TargetTrackingScaling'].PolicyName[]" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $asttScalingPolicyName --auto-scaling-group-name $asgName --policy-type TargetTrackingScaling --cooldown 300 --target-tracking-configuration "{
                `"PredefinedMetricSpecification`": {`"PredefinedMetricType`": `"ASGAverageCPUUtilization`"},
                `"TargetValue`": 70.0,
                `"DisableScaleIn`": false
            }" --no-cli-pager

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"
        # aws autoscaling put-scaling-policy --policy-name $asttScalingPolicyName --auto-scaling-group-name $asgName --policy-type TargetTrackingScaling --cooldown 300 --target-tracking-configuration "{
        #         `"PredefinedMetricSpecification`": {`"PredefinedMetricType`": `"ASGAverageCPUUtilization`"},
        #         `"TargetValue`": 30.0,
        #         `"DisableScaleIn`": false
        #     }" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asttScalingPolicyName1' || PolicyName=='$asttScalingPolicyName2'].PolicyName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "TARGET TRACKING SCALING POLICY EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asttScalingPolicyName = "asttScalingPolicy1"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"
    if ((aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asttScalingPolicyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as target tracking scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='TargetTrackingScaling'].PolicyName[]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $asttScalingPolicyName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as target tracking scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='TargetTrackingScaling'].PolicyName[]" --output text
    } else {Write-Output "Não existe a target tracking scaling policy de nome $asttScalingPolicyName no auto scaling group $asgName"}
} else {Write-Host "Código não executado"}