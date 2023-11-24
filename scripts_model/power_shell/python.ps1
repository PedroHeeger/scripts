#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "PYTHON AND PIP INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
$filePath = "C:\zProgramsTI\zdownloads"
$file = "python"
$folderPath = "C:\zProgramsTI\python\3.12.0"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando o pacote"
    Invoke-WebRequest -Uri "$link" -OutFile (Join-Path $filePath $file.zip)

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando o diretório"
    New-Item -ItemType Directory -Path "$folderPath" -Force

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Descompactando o pacote"
    Expand-Archive -Path "$filePath\$file.zip" -DestinationPath "$folderPath"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Adicionando ao Path"
    $env:PATH += ";$folderPath"
} else {Write-Host "Código não executado"}