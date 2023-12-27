#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CLUSTER FARGATE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterFargateTest1"
capacityProviderName="FARGATE"
region="us-east-1"
accountId="001727357081"
clusterArn="arn:aws:ecs:${region}:${accountId}:cluster/${clusterName}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    if [ "$(aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text | wc -l)" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
        # Split-Path (aws ecs list-clusters --query "clusterArns[?clusterArns==`"${clusterArn}`"]" --output text) -Leaf
        # aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um cluster de nome $clusterName"
        aws ecs create-cluster --cluster-name $clusterName --settings "name=containerInsights,value=enabled" --capacity-providers $capacityProviderName --default-capacity-provider-strategy "capacityProvider=$capacityProviderName,weight=1" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
        # Split-Path (aws ecs list-clusters --query "clusterArns[?clusterArns==`"${clusterArn}`"]" --output text) -Leaf
        # aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CLUSTER FARGATE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
cluster_name="clusterFargateTest1"
region="us-east-1"
account_id="001727357081"
cluster_arn="arn:aws:ecs:${region}:${account_id}:cluster/${cluster_name}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $cluster_name"
    if [ $(aws ecs list-clusters --query "clusterArns[?contains(@, '${cluster_arn}')]" --output text | wc -w) -gt 1 ]; then
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