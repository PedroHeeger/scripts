#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "LOG GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$logGroupName = "/aws/ecs/ec2/taskEc2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o log group de nome $logGroupName"
    if ((aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o log group de nome $logGroupName"
        aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o log group de nome $logGroupName"
        aws logs create-log-group --log-group-name $logGroupName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o log group de nome $logGroupName"
        aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "LOG GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$logGroupName = "/aws/ecs/ec2/taskEc2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o log group de nome $logGroupName"
    if ((aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o log group de nome $logGroupName"
        aws logs delete-log-group --log-group-name $logGroupName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text
    } else {Write-Output "Não existe o log group de nome $logGroupName"}
} else {Write-Host "Código não executado"}