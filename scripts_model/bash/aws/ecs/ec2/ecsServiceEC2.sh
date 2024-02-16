#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "SERVICE EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
serviceName="svcEC2Test1"
clusterName="clusterEC2Test1"
taskName="taskEC2Test1"
taskVersion="6"
taskAmount=2
launchType="EC2"
tgName="tgTest1"
containerName1="containerTest1"
containerPort1=8080

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o serviço de nome $serviceName no cluster $clusterName (Ignorando erro)..."
    erro="ClientException"
    if aws ecs describe-services --cluster "$clusterName" --services "$serviceName" --query "services[].status" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws ecs describe-services --cluster "$clusterName" --services "$serviceName" --query "services[].status" --output text)
    fi
    
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o serviço de nome $serviceName no cluster $clusterName"
    excludedStatus=("ACTIVE" "0")
    if [[ " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster "$clusterName" --services "$serviceName" --query "services[?serviceName=='$serviceName'].serviceName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os serviços no cluster $clusterName"
        aws ecs list-services --cluster "$clusterName" --query "serviceArns" --output text

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Extraindo o ARN do target group $tgName"
        # tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text
   
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs create-service --cluster "$clusterName" --service-name "$serviceName" --task-definition "${taskName}:${taskVersion}" --desired-count "$taskAmount" --launch-type "$launchType" --scheduling-strategy REPLICA --deployment-configuration "minimumHealthyPercent=25,maximumPercent=200" --no-cli-pager

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando o serviço de nome $serviceName no cluster $clusterName"
        # aws ecs create-service --cluster "$clusterName" --service-name "$serviceName" --task-definition "${taskName}:${taskVersion}" --desired-count "$taskAmount" --launch-type "$launchType" --scheduling-strategy REPLICA --deployment-configuration "minimumHealthyPercent=25,maximumPercent=200" --load-balancers "targetGroupArn=$tgArn,containerName=$containerName1,containerPort=$containerPort1" --placement-constraints "type=distinctInstance" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster "$clusterName" --services "$serviceName" --query "services[?serviceName=='$serviceName'].serviceName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o serviço de nome $serviceName no cluster $clusterName (Ignorando erro)..."
    erro="InvalidParameterException"
    if aws ecs describe-services --cluster "$clusterName" --services "$serviceName" --query "services[].status" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws ecs describe-services --cluster "$clusterName" --services "$serviceName" --query "services[].status" --output text)
    fi
    
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o serviço de nome $serviceName no cluster $clusterName"
    excludedStatus=("ACTIVE" "0")
    if [[ " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os serviços criados no $clusterName"
        aws ecs list-services --cluster "$clusterName" --query "serviceArns" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Atualizando a quantidade desejada de tarefas do serviço de nome $serviceName para 0"
        aws ecs update-service --cluster "$clusterName" --service "$serviceName" --desired-count 0 --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o serviço de nome $serviceName do cluster $clusterName"
        aws ecs delete-service --cluster "$clusterName" --service "$serviceName" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todos os serviços criados no $clusterName"
        aws ecs list-services --cluster "$clusterName" --query "serviceArns" --output text
    else
        echo "Não existe o cluster de nome $clusterName"
    fi
else
    echo "Código não executado"
fi