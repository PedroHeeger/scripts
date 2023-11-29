#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "CHOCOLATEY INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://chocolatey.org/install.ps1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Alterando a política de execução para Bypass durante a sessão atual"
    Set-ExecutionPolicy Bypass -Scope Process -Force

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Atualizando os protocolos de segurança para incluir o TLS 1.2"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando e executando o script de instalação"   
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("${link}")) 
} else {Write-Host "Código não executado"}