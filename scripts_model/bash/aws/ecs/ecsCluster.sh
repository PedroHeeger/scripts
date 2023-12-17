#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CLUSTER CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterTest1"
launchType="FARGATE"
region="us-east-1"
accountId="001727357081"
clusterArn="arn:aws:ecs:${region}:${accountId}:cluster/${clusterName}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    if [ $(aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
        # basename $(aws ecs list-clusters --query "clusterArns[?clusterArns==\"${clusterArn}\"]" --output text)
        # aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um cluster de nome $clusterName"
        aws ecs create-cluster --cluster-name $clusterName --settings "name=containerInsights,value=enabled" --capacity-providers $launchType --default-capacity-provider-strategy "capacityProvider=$launchType,weight=1" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
        # basename $(aws ecs list-clusters --query "clusterArns[?clusterArns==\"${clusterArn}\"]" --output text)
        # aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CLUSTER EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
cluster_name="clusterTest1"
region="us-east-1"
account_id="001727357081"
cluster_arn="arn:aws:ecs:${region}:${account_id}:cluster/${cluster_name}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $cluster_name"
    if [ $(aws ecs list-clusters --query "clusterArns[?contains(@, '${cluster_arn}')]" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o cluster de nome $cluster_name"
        aws ecs delete-cluster --cluster $cluster_name --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    else
        echo "Não existe o cluster de nome $cluster_name"
    fi
else
    echo "Código não executado"
fi