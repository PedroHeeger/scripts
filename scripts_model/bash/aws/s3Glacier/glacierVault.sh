#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3 GLACIER"
echo "VAULT CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
vaultName="vaultTest1"
accountId="-"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cofre de nome $vaultName"
    if [[ $(aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o cofre de nome $vaultName"
        aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o cofre de nome $vaultName"
        aws glacier create-vault --account-id $accountId --vault-name $vaultName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o cofre de nome $vaultName"
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
vaultName="vaultEdn1"
accountId="-"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cofre de nome $vaultName"
    if [[ $(aws glacier list-vaults --account-id $accountId --query "VaultList[?VaultName=='$vaultName'].VaultName" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o cofre de nome $vaultName"
        aws glacier delete-vault --account-id $accountId --vault-name $vaultName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os cofres da conta determinada"
        aws glacier list-vaults --account-id $accountId --query "VaultList[].VaultName" --output text
    else
        echo "Não existe o cofre de nome $vaultName"
    fi
else
    echo "Código não executado"
fi