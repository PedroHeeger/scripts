#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "TASK EXECUTION ON CLUSTER FARGATE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
taskName="taskFargateTest1"
revision="2"
clusterName="clusterFargateTest1"
launchType="FARGATE"
region="us-east-1"
availabilityZone1="us-east-1a"
availabilityZone2="us-east-1b"
accountId="001727357081"
taskArn="arn:aws:ecs:${region}:${accountId}:task/${clusterName}"
taskDefinitionArn="arn:aws:ecs:${region}:${accountId}:task-definition/${taskName}:${revision}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Criando uma função para executar a tarefa de nome $taskName se ela não existir no cluster $clusterName"
    ExecutarTarefa() {
        local taskName=$1
        local revision=$2
        local clusterName=$3
        local launchType=$4
        local availabilityZone1=$5
        local availabilityZone2=$6

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todas as tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os elementos de rede"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text)
        subnetId1=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        subnetId2=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        sgId=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=default" --query "SecurityGroups[].GroupId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Executando a tarefa de nome $taskName no cluster $clusterName"
        aws ecs run-task --task-definition ${taskName}:${revision} --cluster $clusterName --launch-type $launchType --network-configuration "awsvpcConfiguration={subnets=[$subnetId1,$subnetId2],securityGroups=[$sgId],assignPublicIp=ENABLED}" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o Id da tarefa de nome $taskName no cluster $clusterName"
        taskId=$(basename $(aws ecs list-tasks --cluster $clusterName --query "taskArns[?contains(@, '$taskArn')]" --output text))
        echo $taskId
    }

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a tarefa de nome $taskName no cluster $clusterName"
    if [ $(aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando uma lista de ARNs das revisões da tarefa de nome $taskName do cluster $clusterName"
        taskArnsString=$(aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns" --output text)
        taskArnsList=($taskArnsString)
        echo "${taskArnsList[@]}"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
        for taskArn in "${taskArnsList[@]}"; do
            if [ "$(aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text)" == "$taskDefinitionArn" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text
            else
                ExecutarTarefa $taskName $revision $clusterName $launchType $availabilityZone1 $availabilityZone2
            fi
        done
    else
        ExecutarTarefa $taskName $revision $clusterName $launchType $availabilityZone1 $availabilityZone2
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "TASK EXCLUSION ON CLUSTER FARGATE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
taskName="taskFargateTest1"
clusterName="clusterFargateTest1"
revision="2"
region="us-east-1"
accountId="001727357081"
taskDefinitionArn="arn:aws:ecs:${region}:${accountId}:task-definition/${taskName}:${revision}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a tarefa de nome $taskName no cluster $clusterName"
    taskArnsString=$(aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns" --output text)
    taskArnsList=($taskArnsString)
    
    if [ ${#taskArnsList[@]} -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando uma lista de ARNs das revisões da tarefa de nome $taskName no cluster $clusterName"
        echo "${taskArnsList[@]}"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
        for taskArn in "${taskArnsList[@]}"; do
            if [ "$(aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text)" == "$taskDefinitionArn" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando as ARNs de todas as tarefas no cluster $clusterName"
                aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Interrompendo a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
                aws ecs stop-task --task $taskArn --cluster $clusterName --no-cli-pager

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando as ARNs de todas as tarefas no cluster $clusterName"
                aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Não existe a tarefa $taskName no cluster $clusterName na revisão $revision"
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text
            fi
        done
    else
        echo "Não existe a tarefa $taskName no cluster $clusterName"
    fi
else
    echo "Código não executado"
fi