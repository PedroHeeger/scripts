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