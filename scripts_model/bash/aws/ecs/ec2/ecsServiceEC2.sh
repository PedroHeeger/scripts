#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "SERVICE EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
serviceName="svcEC2Test1"
clusterName="clusterEC2Test1"
taskName="taskEC2Test1"
taskVersion="1"
taskAmount=2
launchType="EC2"
# aZ1="us-east-1a"
# aZ2="us-east-1b"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "Verificando se existe o serviço de nome $serviceName no cluster $clusterName (Ignorando erro)..."
    erro="ClientException"
    if aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName' && status=='ACTIVE'].serviceName" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName' && status=='ACTIVE'].serviceName" | jq length)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o serviço de nome $serviceName no cluster $clusterName"
    if [ $condition -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName'].serviceName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os serviços no cluster $clusterName"
        aws ecs list-services --cluster $clusterName --query "serviceArns" --output text

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Extraindo os elementos de rede"
        # vpcId=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text)
        # subnetId1=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        # subnetId2=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        # sgId=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=default" --query "SecurityGroups[].GroupId" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs create-service --cluster $clusterName --service-name $serviceName --task-definition "${taskName}:${taskVersion}" --desired-count $taskAmount --launch-type $launchType --scheduling-strategy REPLICA --deployment-configuration minimumHealthyPercent=25,maximumPercent=200 --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName'].serviceName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "SERVICE EC2 EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
serviceName="svcEC2Test1"
clusterName="clusterEC2Test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    if [ $(aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[].serviceName" | jq length) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os serviços criados no $clusterName"
        aws ecs list-services --cluster $clusterName --query "serviceArns" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Atualizando a quantidade desejada de tarefas do serviço de nome $serviceName para 0"
        aws ecs update-service --cluster $clusterName --service $serviceName --desired-count 0 --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o serviço de nome $serviceName do cluster $clusterName"
        aws ecs delete-service --cluster $clusterName --service $serviceName --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os serviços criados no $clusterName"
        aws ecs list-services --cluster $clusterName --query "serviceArns" --output text
    else
        echo "Não existe o cluster de nome $clusterName"
    fi
else
    echo "Código não executado"
fi