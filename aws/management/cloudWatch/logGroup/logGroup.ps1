#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "LOG GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$logGroupName = "logGroupTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o log group $logGroupName"
    $condition = aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o log group $logGroupName"
        aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o log group $logGroupName"
        aws logs create-log-group --log-group-name $logGroupName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o log group $logGroupName"
        aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON CLOUDWATCH"
Write-Output "LOG GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$logGroupName = "logGroupTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o log group $logGroupName"
    $condition = aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o log group $logGroupName"
        aws logs delete-log-group --log-group-name $logGroupName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text
    } else {Write-Output "Não existe o log group $logGroupName"}
} else {Write-Host "Código não executado"}