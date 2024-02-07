#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CAPACITY PROVIDER CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
capacityProviderName="capacityProviderTest1"
asgName="asgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o fornecedor de capacidade de nome $capacityProviderName"
    count=$(aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name" | wc -l)
    if [ $count -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o fornecedor de capacidade de nome $capacityProviderName"
        aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os fornecedores de capacidade existentes"
        aws ecs describe-capacity-providers --query "capacityProviders[].name[]" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do auto scaling group $asgName"
        asgArn=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?AutoScalingGroupName=='$asgName'].AutoScalingGroupARN" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um fornecedor de capacidade de nome $capacityProviderName"
        aws ecs create-capacity-provider --name $capacityProviderName --auto-scaling-group-provider "autoScalingGroupArn=$asgArn,managedScaling={status=ENABLED,targetCapacity=100},managedTerminationProtection=DISABLED" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o fornecedor de capacidade de nome $capacityProviderName"
        aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "CAPACITY PROVIDER EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
capacityProviderName="capacityProviderTest1"
# clusterName="clusterEC2Test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o fornecedor de capacidade de nome $capacityProviderName"
    count=$(aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name" | wc -l)
    if [ $count -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os fornecedores de capacidade existentes"
        aws ecs describe-capacity-providers --query "capacityProviders[].name[]" --output text

        # Uncomment the following lines if you have a specific cluster to remove the capacity provider from
        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Removendo o fornecedor de capacidade de nome $capacityProviderName do cluster $clusterName"
        # aws ecs put-cluster-capacity-providers --cluster $clusterName --capacity-providers

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o fornecedor de capacidade de nome $capacityProviderName"
        aws ecs delete-capacity-provider --capacity-provider $capacityProviderName --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os fornecedores de capacidade existentes"
        aws ecs describe-capacity-providers --query "capacityProviders[].name[]" --output text
    else
        echo "Não existe o fornecedor de capacidade de nome $capacityProviderName"
    fi
else
    echo "Código não executado"
fi