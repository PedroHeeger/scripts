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

    
} else {Write-Host "Código não executado"}




# #!/usr/bin/env powershell

# Write-Output "***********************************************"
# Write-Output "ANSIBLE INSTALLATION"

# Write-Output "-----//-----//-----//-----//-----//-----//-----"
# Write-Output "Definindo variáveis"
# $link = "https://github.com/ansible/ansible/archive/refs/tags/v2.16.0.zip"
# $filePath = "C:\zProgramsTI\zdownloads"
# $file = "ansible"
# $folderPath = "C:\zProgramsTI\ansible\2.16.0"
# $folderPathBin = "C:\zProgramsTI\ansible\2.16.0"

# Write-Output "-----//-----//-----//-----//-----//-----//-----"
# $resposta = Read-Host "Deseja executar o código? (y/n) "
# if ($resposta.ToLower() -eq 'y') {
#     # Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     # Write-Output "Baixando o pacote"
#     # Invoke-WebRequest -Uri $link -OutFile "$filePath\$file.zip"

#     # Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     # Write-Output "Criando o diretório"
#     # New-Item -ItemType Directory -Path "$folderPath" -Force

#     # Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     # Write-Output "Descompactando o pacote"
#     # Expand-Archive -Path "$filePath\$file.zip" -DestinationPath "$folderPath"

#     # Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     # Write-Output "Obtendo todos os itens da pasta descompactada"
#     # $items = Get-ChildItem -Path $folderPath

#     # Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     # Write-Output "Verificando se há apenas uma pasta descompactada ou se os arquivos estão soltos"
#     # if ($items.Count -eq 1 -and $items[0].PSIsContainer) {
#     #     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     #     Write-Output "Extraindo o nome desta pasta"
#     #     $contentPath = $items[0].FullName

#     #     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     #     Write-Output "Movendo os arquivos dessa pasta para pasta criada"
#     #     Move-Item -Path (Join-Path $contentPath "*") -Destination $folderPath -Force

#     #     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     #     Write-Output "Removendo a pasta da descompactação"
#     #     Remove-Item -Path $contentPath -Force -Recurse
#     # }   

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Adicionando ao Path"
#     # $env:PATH += ";$($folderPath)"

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Obtendo o valor atual do PATH do sistema"
#     $systemPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Verificando se o novo caminho não já está presente no PATH"
#     if (-not ($systemPath -split ';' -contains $folderPath)) {
#         Write-Output "-----//-----//-----//-----//-----//-----//-----"
#         Write-Output "Adicionando o novo caminho ao PATH do sistema"
#         $systemPath += ";$folderPathBin"

#         # Write-Output "-----//-----//-----//-----//-----//-----//-----"
#         # Write-Output "Adicionando ao Path"
#         # $systemPath -split ';'

#         Write-Output "-----//-----//-----//-----//-----//-----//-----"
#         Write-Output "Atualizando o PATH do sistema"
#         # [System.Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)

#         Write-Output "-----//-----//-----//-----//-----//-----//-----"
#         Write-Output "Adicionando ao Path"
#         # $env:PATH = $systemPath
#     } else {
#         Write-Output "O caminho já está presente no PATH do sistema."
#     }

    
#     # [System.Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)
# } else {Write-Host "Código não executado"}