#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "KUBECTL INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Instalando o pacote"
    choco install kubernetes-cli

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Exibindo a versão"
    kubectl version --client
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "KUBECTL CONFIGURATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://winscp.net/download/WinSCP-6.1.2-Setup.exe"
$downloadFolder = "C:\zProgramsTI\zdownloads"
$file = "WinSCP-6.1.2-Setup.exe"
$installDir = "C:\zProgramsTI\winscp"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Navegando até o diretório inicial do usuário"
    Set-Location ~

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando o diretório .kube"
    mkdir .kube

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Entrando no diretório .kube"
    Set-Location .kube

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Configurando o kubectl para usar um cluster Kubernetes remoto"
    New-Item config -type file

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se o kubectl está configurado corretamente obtendo o estado do cluster"
    kubectl cluster-info
} else {Write-Host "Código não executado"}