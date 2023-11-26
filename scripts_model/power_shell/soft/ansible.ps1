#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "ANSIBLE INSTALLATION (Pip)"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$folderPath = "C:\zProgramsTI\ansible\2.16.0"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando o diretório"
    New-Item -ItemType Directory -Path "$folderPath" -Force

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando e instalando o pacote"
    pip install ansible --target $folderPath

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