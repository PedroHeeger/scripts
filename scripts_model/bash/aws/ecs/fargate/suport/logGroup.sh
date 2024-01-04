#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON CLOUDWATCH"
echo "LOG GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
logGroupName="/aws/ecs/fargate/taskFargateTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o log group de nome $logGroupName"
    if [ "$(aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text | wc -l)" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o log group de nome $logGroupName"
        aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o log group de nome $logGroupName"
        aws logs create-log-group --log-group-name "$logGroupName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o log group de nome $logGroupName"
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
logGroupName="/aws/ecs/fargate/taskFargateTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o log group de nome $logGroupName"
    if [ "$(aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" --output text | wc -l)" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o log group de nome $logGroupName"
        aws logs delete-log-group --log-group-name "$logGroupName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os log groups existentes"
        aws logs describe-log-groups --query "logGroups[].logGroupName" --output text
    else
        echo "Não existe o log group de nome $logGroupName"
    fi
else
    echo "Código não executado"
fi