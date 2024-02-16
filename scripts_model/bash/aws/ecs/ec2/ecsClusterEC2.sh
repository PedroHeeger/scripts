#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CLUSTER EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterEC2Test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    erro="ResourceNotFoundException"
    if aws ecs describe-clusters --clusters "$clusterName" --query "clusters[].status" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws ecs describe-clusters --clusters "$clusterName" --query "clusters[].status" --output text)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    excludedStatus=("ACTIVE" "CREATING" "0")
    if [[ " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um cluster de nome $clusterName"
        aws ecs create-cluster --cluster-name $clusterName --settings "name=containerInsights,value=enabled" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CLUSTER EC2 EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterEC2Test1"
logGroupName="/aws/ecs/containerinsights/${clusterName}/performance"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    erro="ResourceNotFoundException"
    if aws ecs describe-clusters --clusters "$clusterName" --query "clusters[].status" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws ecs describe-clusters --clusters "$clusterName" --query "clusters[].status" --output text)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    excludedStatus=("ACTIVE" "CREATING" "0")
    if [[ " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o cluster de nome $clusterName"
        aws ecs delete-cluster --cluster $clusterName --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o log group de nome $logGroupName"
        if [ $(aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName" | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o log group de nome $logGroupName"
            aws logs delete-log-group --log-group-name $logGroupName
        else
            echo "Não existe o log group de nome $logGroupName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    else
        echo "Não existe o cluster de nome $clusterName"
    fi
else
    echo "Código não executado"
fi