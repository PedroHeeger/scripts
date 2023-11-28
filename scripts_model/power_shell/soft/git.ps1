#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "GIT INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
$filePath = "C:\zProgramsTI\zdownloads"
$file = "git.exe"
$folderPath = "C:\zProgramsTI\git"

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
    Write-Output "Executando o instalador"
    Start-Process -Wait -FilePath "$filePath\$file"

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
Write-Output "GIT CONFIGURATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$userName = "PedroHeeger"
$userEmail = "pedroheeger19@gmail.com"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Configurando o nome de usuário"
    git config --global user.name "$userName"

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Configurando o email do usuário"
    git config --global user.email "$userEmail"
} else {Write-Host "Código não executado"}