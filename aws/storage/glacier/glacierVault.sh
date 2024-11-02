#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3 GLACIER"
echo "VAULT CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
vaultName="vaultTest1"
accountId="-"  # Utiliza a configurada na AWS CLI
tagName="tagVaultTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cofre $vaultName"
    condition=$(aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text | wc -w)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o cofre $vaultName"
        aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o cofre $vaultName"
        aws glacier create-vault --account-id $accountId --vault-name $vaultName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Adicionando a tag $tagName para o cofre $vaultName"
        aws glacier add-tags-to-vault --account-id $accountId --vault-name $vaultName --tags "Name=$tagName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o cofre $vaultName"
        aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3 GLACIER"
echo "VAULT EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
vaultName="vaultTest1"
accountId="-"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cofre $vaultName"
    condition=$(aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text | wc -w)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o cofre $vaultName"
        aws glacier delete-vault --account-id $accountId --vault-name $vaultName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text
    else
        echo "Não existe o cofre $vaultName"
    fi
else
    echo "Código não executado"
fi