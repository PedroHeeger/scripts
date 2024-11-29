#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "LOG GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
logGroupName="logGroupTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o log group $logGroupName"
    condition=$(aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o log group $logGroupName"
        aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o log group $logGroupName"
        aws logs create-log-group --log-group-name "$logGroupName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o log group $logGroupName"
        aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "LOG GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
logGroupName="logGroupTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    condition=$(aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o log group $logGroupName"
        aws logs delete-log-group --log-group-name "$logGroupName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text
    else
        echo "Não existe o log group $logGroupName"
    fi
else
    echo "Código não executado"
fi