#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "PYTHON INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
$filePath = "C:\zProgramsTI\zdownloads"
$file = "python.zip"
$folderPath = "C:\zProgramsTI\python\3.12.0"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando o pacote"
    Invoke-WebRequest -Uri "$link" -OutFile "$filePath\$file"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando o diretório"
    New-Item -ItemType Directory -Path "$folderPath" -Force

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Descompactando o pacote"
    Expand-Archive -Path "$filePath\$file.zip" -DestinationPath "$folderPath"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Obtendo o valor atual do PATH"
    $pathAtual = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se o diretório já está no PATH"
    if (-not ($pathAtual -split ';' -contains $folderPath)) { 
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Adicionando o diretório ao PATH"
        $novoPath += "$folderPath;$pathAtual"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Definindo o novo valor do PATH"
        [System.Environment]::SetEnvironmentVariable("PATH", $novoPath, [System.EnvironmentVariableTarget]::Machine)
    } else {Write-Output "O diretório já está presente no PATH."}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "PIP INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://bootstrap.pypa.io/get-pip.py"
$file = "get-pip.py"
$folderPathDestination = "C:\zProgramsTI\python\3.12.0"
$folderPath = "C:\zProgramsTI\python\3.12.0\Scripts"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando o pacote"
    (Invoke-WebRequest -Uri "$link" -OutFile "$folderPathDestination\$file").Content

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Instalando o pacote"
    python get-pip.py

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Obtendo o valor atual do PATH"
    $pathAtual = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se o diretório já está no PATH"
    if (-not ($pathAtual -split ';' -contains $folderPath)) { 
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Adicionando o diretório ao PATH"
        $novoPath += "$folderPath;$pathAtual"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Definindo o novo valor do PATH"
        [System.Environment]::SetEnvironmentVariable("PATH", $novoPath, [System.EnvironmentVariableTarget]::Machine)
    } else {Write-Output "O diretório já está presente no PATH."}
} else {Write-Host "Código não executado"}