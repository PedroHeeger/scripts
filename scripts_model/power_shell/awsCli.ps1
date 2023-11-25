#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "AWS CLI INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://awscli.amazonaws.com/AWSCLIV2.msi"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando e instalando o pacote"
    msiexec.exe /i "$link" /qn
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "AWS CLI CONFIGURATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$accessKey = "SEU_ACCESS_KEY"
$secretKey = "SEU_SECRET_KEY"
$region = "us-east-1"
$outputFormat = "json"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Configurando as credenciais"
    aws configure set aws_access_key_id $accessKey
    aws configure set aws_secret_access_key $secretKey

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Configurando a região e o formato de saída dos dados"
    aws configure set default.region $region
    aws configure set default.output $outputFormat
} else {Write-Host "Código não executado"}