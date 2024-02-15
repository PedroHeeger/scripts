#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "MINIKUBE INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe"
$file = "minikube-installer.exe"
$folderPath = "C:\zProgramsTI\minikube"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando o diretório"
    New-Item -ItemType Directory -Path $folderPath -Force

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando o arquivo de instalação"
    Invoke-WebRequest -Uri $link -OutFile "$folderPath\$file"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Instalando o software"
    Start-Process -FilePath "$folderPath\$file" -NoNewWindow

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