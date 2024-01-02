#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "TARGET GROUP ADD INSTANCE EC2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tgName = "tgTest1"
$tagNameInstance = "ec2Test"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do target group $tgName"
    $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo o Id da instância $tagNameInstance"
    $instanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância $tagNameInstance no target group $tgName"
    if ((aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a instância $tagNameInstance no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[]"
   
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Registrando a instância $tagNameInstance no target group $tgName"
        aws elbv2 register-targets --target-group-arn $tgArn --targets Id=$instanceId

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a instância $tagNameInstance no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "TARGET GROUP REMOVE INSTANCE EC2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tgName = "tgTest1"
$tagNameInstance = "ec2Test"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do target group $tgName"
    $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo o Id da instância $tagNameInstance"
    $instanceId = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância $tagNameInstance no target group $tgName"
    if ((aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a instância $tagNameInstance no target group $tgName"
        aws elbv2 deregister-targets --target-group-arn $tgArn --targets Id=$instanceId

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text
    } else {Write-Output "Não existe o target group de nome $tgName"}
} else {Write-Host "Código não executado"}