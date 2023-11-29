#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "FILEZILLA INSTALLATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$link = "https://download.filezilla-project.org/client/FileZilla_3.55.1_win64_sponsored-setup.exe"
$downloadFolder = "C:\zProgramsTI\zdownloads"
$file = "FileZilla_3.55.1_win64_sponsored-setup.exe"
$installDir = "C:\zProgramsTI\filezilla"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Baixando o instalador"
    Invoke-WebRequest -Uri $link -OutFile "$downloadFolder\$file" -Headers @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" }

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Executando o instalador"
    Start-Process -FilePath "$downloadFolder\$file" -ArgumentList "/SP- /VERYSILENT /NORESTART /SUPPRESSMSGBOXES /D=$installDir" -Wait
} else {Write-Host "Código não executado"}