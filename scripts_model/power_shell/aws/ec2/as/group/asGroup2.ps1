#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "AUTO SCALING GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asgName = "asgTest1"
$launchTempName = "launchTempTest1"
$versionNumber = 1
$clbName = "clbTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o auto scaling group de nome $asgName"
    if ((aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?AutoScalingGroupName=='$asgName'].AutoScalingGroupName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o auto scaling group de nome $asgName"
        aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?AutoScalingGroupName=='$asgName'].AutoScalingGroupName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os auto scaling groups existentes"
        aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[].AutoScalingGroupName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o auto scaling group de nome $asgName"
        aws autoscaling create-auto-scaling-group --auto-scaling-group-name $asgName --launch-template "LaunchTemplateName=$launchTempName,Version=$versionNumber" --min-size 1 --max-size 4 --desired-capacity 1 --default-cooldown 300 --health-check-type EC2 --health-check-grace-period 300 --load-balancer-names $clbName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Habilitando a coleta de métricas do auto scaling group de nome $asgName"
        aws autoscaling enable-metrics-collection --auto-scaling-group-name $asgName --metrics "GroupMinSize" "GroupMaxSize" "GroupDesiredCapacity" "GroupInServiceInstances" "GroupPendingInstances" "GroupStandbyInstances" "GroupTerminatingInstances" "GroupTotalInstances" --granularity "1Minute"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o auto scaling group de nome $asgName"
        aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?AutoScalingGroupName=='$asgName'].AutoScalingGroupName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "AUTO SCALING GROUP EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o auto scaling group de nome $asgName"
    if ((aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?AutoScalingGroupName=='$asgName'].AutoScalingGroupName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os grupos de auto scaling existentes"
        aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[].AutoScalingGroupName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o auto scaling group de nome $asgName"
        aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $asgName --force-delete

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os grupos de auto scaling existentes"
        aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[].AutoScalingGroupName" --output text
    } else {Write-Output "Não existe o auto scaling group de nome $asgName"}
} else {Write-Host "Código não executado"}