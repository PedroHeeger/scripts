#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "AUTO SCALING GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$asgName = "asgTest1"
$launchConfigurationName = "launchConfigurationTest1"
$availabilityZone1 = "us-east-1a"
$availabilityZone2 = "us-east-1b"

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
        Write-Output "Extraindo os IDs dos elementos de rede"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        $subnetId1 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $subnetId2 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        # $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=default" --query "SecurityGroups[].GroupId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um auto scaling group de nome $asgName"
        aws autoscaling create-auto-scaling-group --auto-scaling-group-name $asgName --launch-configuration-name $launchConfigurationName --min-size 1 --max-size 1 --desired-capacity 1 --vpc-zone-identifier "$subnetId1,$subnetId2"

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