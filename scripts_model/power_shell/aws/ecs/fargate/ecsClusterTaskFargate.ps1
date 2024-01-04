#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EXECUTION ON CLUSTER FARGATE"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskFargateTest1"
$revision = "4"
$clusterName = "clusterFargateTest1"
$launchType = "FARGATE"
$region = "us-east-1"
$az1 = "us-east-1a"
$az2 = "us-east-1b"
$groupName = "default"
$accountId = "001727357081"
$taskArn = "arn:aws:ecs:${region}:${accountId}:task/${clusterName}"
$taskDefinitionArn = "arn:aws:ecs:${region}:${accountId}:task-definition/${taskName}:${revision}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {  
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando uma função para executar a tarefa de nome $taskName se ela não existir no cluster $clusterName"
    function ExecutarTarefa {
        param([string]$taskName, [string]$revision, [string]$clusterName, [string]$launchType, [string]$az1, [string]$az2)

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os elementos de rede"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        $subnetId1 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$az1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $subnetId2 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$az2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$groupName" --query "SecurityGroups[].GroupId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Executando a tarefa de nome $taskName no cluster $clusterName"
        aws ecs run-task --task-definition ${taskName}:${revision} --cluster $clusterName --launch-type $launchType --network-configuration "awsvpcConfiguration={subnets=[$subnetId1,$subnetId2],securityGroups=[$sgId],assignPublicIp=ENABLED}" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o Id da tarefa de nome $taskName no cluster $clusterName"
        $taskId = Split-Path (aws ecs list-tasks --cluster $clusterName --query "taskArns[?contains(@, '$taskArn')]" --output text) -Leaf
        Write-Output $taskId
   }

    
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a tarefa de nome $taskName no cluster $clusterName"
    if ((aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando uma lista de ARNs das revisões da tarefa de nome $taskName do cluster $clusterName"
        $taskArnsString = aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns" --output text
        $taskArnsList = $taskArnsString -split ' '
        Write-Output($taskArnsList)

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
        foreach ($taskArn in $taskArnsList) {
            if ((aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text) -eq $taskDefinitionArn) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text
            } else {ExecutarTarefa $taskName $revision $clusterName $launchType $az1 $az2}}
    } else {ExecutarTarefa $taskName $revision $clusterName $launchType $az1 $az2}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EXCLUSION ON CLUSTER FARGATE"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskFargateTest1"
$clusterName = "clusterFargateTest1"
$revision = "4"
$region = "us-east-1"
$accountId = "001727357081"
$taskDefinitionArn = "arn:aws:ecs:${region}:${accountId}:task-definition/${taskName}:${revision}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a tarefa de nome $taskName no cluster $clusterName"
    if ((aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando uma lista de ARNs das revisões da tarefa de nome $taskName no cluster $clusterName"
        $taskArnsString = aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns" --output text
        $taskArnsList = $taskArnsString -split '\s+'
        Write-Output($taskArnsList)

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
        foreach ($taskArn in $taskArnsList) {
            if ((aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text) -eq $taskDefinitionArn) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando as ARNs de todas as tarefas no cluster $clusterName"
                aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
       
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Interrompendo a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
                aws ecs stop-task --task $taskArn --cluster $clusterName --no-cli-pager
    
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando as ARNs de todas as tarefas no cluster $clusterName"
                aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Não existe a tarefa $taskName no cluster $clusterName na revisão $revision"
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text
            }}
    } else {Write-Output "Não existe a tarefa $taskName no cluster $clusterName"}
} else {Write-Host "Código não executado"}