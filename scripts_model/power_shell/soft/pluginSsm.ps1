#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "PLUGIN SESSION MANAGER AWS SYSTEMS MANAGER (SSM) CONFIGURATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPlugin.zip"
$filePath1 = "C:\zProgramsTI\zdownloads"
$file1 = "SessionManagerPlugin.zip"
$filePath2 = "C:\zProgramsTI\zdownloads\SessionManagerPlugin"
$file2 = "package.zip"
$folderPath = "C:\Program Files\Amazon\SessionManagerPlugin"
$folderPathBin = "C:\Program Files\Amazon\SessionManagerPlugin\bin"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando o pacote"
    Invoke-WebRequest -Uri "$link" -OutFile "$filePath\$file1"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando o diretório"
    New-Item -ItemType Directory -Path "$folderPath" -Force

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Descompactando o primeiro pacote"
    Expand-Archive -Path "$filePath1\$file1" -DestinationPath "$filePath2"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Descompactando o segundo pacote"
    Expand-Archive -Path "$filePath\$file" -DestinationPath "$folderPath"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Obtendo o valor atual do PATH"
    $pathAtual = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se o diretório já está no PATH"
    if (-not ($pathAtual -split ';' -contains $folderPathBin)) { 
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Adicionando o diretório ao PATH"
        $novoPath += "$folderPathBin;$pathAtual"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Definindo o novo valor do PATH"
        [System.Environment]::SetEnvironmentVariable("PATH", $novoPath, [System.EnvironmentVariableTarget]::Machine)
    } else {Write-Output "O diretório já está presente no PATH."}
} else {Write-Host "Código não executado"}