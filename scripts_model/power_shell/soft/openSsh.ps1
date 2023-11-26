# #!/usr/bin/env powershell

# Write-Output "***********************************************"
# Write-Output "OPENSSH INSTALLATION"

# Write-Output "-----//-----//-----//-----//-----//-----//-----"
# $resposta = Read-Host "Deseja executar o código? (y/n) "
# if ($resposta.ToLower() -eq 'y') {
#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Verificando se o Client e o Server estão instalados"
#     Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Instalando o Client"
#     Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Instalando o Server"
#     Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Iniciando o serviço"
#     Start-Service sshd

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Definindo que o serviço deve ser iniciado automaticamente"
#     Set-Service -Name sshd -StartupType 'Automatic'

#     Write-Output "-----//-----//-----//-----//-----//-----//-----"
#     Write-Output "Verificando se existe regra do Firewall configurada"
#     if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
#         Write-Output "-----//-----//-----//-----//-----//-----//-----"
#         Write-Output "Configurando a regra 'OpenSSH-Server-In-TCP'"
#         New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
#     } else {Write-Output "A regra de Firewall 'OpenSSH-Server-In-TCP' já existe"}
# } else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "OPENSSH CREATION KEY"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$keyPairName = "keyPair1"
$keyPairPath = "G:\Meu Drive\4_PROJ\scripts\scripts_model\power_shell\.default"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando uma chave com senha vazia e gerando os arquivos .pub (pública) e .pem (privada)"
    ssh-keygen -t rsa -b 2048 -N "" -f "$keyPairPath\$keyPairName.pem"
} else {Write-Host "Código não executado"}