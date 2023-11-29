#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o grupo de nome $iamGroupName"
    if [ $(aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o grupo de nome $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o grupo de nome $iamGroupName"
        aws iam create-group --group-name $iamGroupName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o grupo de nome $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM GROUP EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o grupo de nome $iamGroupName"
    if [ $(aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o grupo de nome $iamGroupName"
        aws iam delete-group --group-name $iamGroupName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text
    else
        echo "Não existe o grupo de nome $iamGroupName"
    fi
else
    echo "Código não executado"
fi