#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3 GLACIER"
Write-Output "VAULT CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$vaultName = "vaultTest1"
$accountId = "-"  # Utiliza a configurada na AWS CLI
$tagName = "tagVaultTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cofre $vaultName"
    $condition = aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o cofre $vaultName"
        aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o cofre $vaultName"
        aws glacier create-vault --account-id $accountId --vault-name $vaultName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Adicionando a tag $tagName para o cofre $vaultName"
        aws glacier add-tags-to-vault --account-id $accountId --vault-name $vaultName --tags "Name=$tagName"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o cofre $vaultName"
        aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3 GLACIER"
Write-Output "VAULT EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$vaultName = "vaultTest1"
$accountId = "-"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cofre $vaultName"
    $condition = aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o cofre $vaultName"
        aws glacier delete-vault --account-id $accountId --vault-name $vaultName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text
    } else {Write-Output "Não existe o cofre $vaultName"}
} else {Write-Host "Código não executado"}