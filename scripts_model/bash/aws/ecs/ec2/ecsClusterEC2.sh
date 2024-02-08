#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CLUSTER EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterEC2Test1"
region="us-east-1"
accountId="001727357081"
clusterArn="arn:aws:ecs:${region}:${accountId}:cluster/${clusterName}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    if [ $(aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se o cluster de nome $clusterName está ativo"
        if [ $(aws ecs describe-clusters --clusters $clusterArn --query "clusters[?status=='ACTIVE'].clusterName" | wc -l) -gt 1 ]; then
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
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se o cluster de nome $clusterName está ativo"
        if [ $(aws ecs describe-clusters --clusters $clusterArn --query "clusters[?status=='ACTIVE'].clusterName" | wc -l) -gt 1 ]; then
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
region="us-east-1"
accountId="001727357081"
clusterArn="arn:aws:ecs:${region}:${accountId}:cluster/${clusterName}"
logGroupName="/aws/ecs/containerinsights/${clusterName}/performance"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    if [ $(aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se o cluster de nome $clusterName está ativo"
        if [ $(aws ecs describe-clusters --clusters $clusterArn --query "clusters[?status=='ACTIVE'].clusterName" | wc -l) -gt 1 ]; then
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
            echo "O cluster de nome $clusterName não está ativo"
        fi
    else
        echo "Não existe o cluster de nome $clusterName"
    fi
else
    echo "Código não executado"
fi