#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EXECUTION ON CLUSTER"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskDefinitionName = "taskDefinitionTest1"
$revision = "4"
$clusterName = "clusterTest1"
$launchType = "FARGATE"
$region = "us-east-1"
$availabilityZone1 = "us-east-1a"
$availabilityZone2 = "us-east-1b"
$accountId = "001727357081"
$taskDefinitionArn = "arn:aws:ecs:${region}:${accountId}:task/${taskDefinitionName}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {  
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a definição de tarefa $taskDefinitionName no cluster $clusterName"
    # if ((aws ecs list-tasks --cluster $clusterName --query "taskArns[?contains(@, '$taskDefinitionArn')]").Count -gt 1) {
    if ((aws ecs list-tasks --cluster $clusterName --family $taskDefinitionName --desired-status RUNNING --query "taskArns").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando uma lista de ARNs das tarefas construídas pela definição de tarefa $taskDefinitionName no cluster $clusterName"
        $taskArnsString = aws ecs list-tasks --cluster $clusterName --family $taskDefinitionName --desired-status RUNNING --query "taskArns" --output text
        $taskArnsList = $taskArnsString -split ' '

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a definição de tarefa $taskDefinitionName no cluster $clusterName na revisão $revision"
        foreach ($taskArn in $taskArnsList) {
            if ((aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].version" --output text) -eq $revision) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe a definição de tarefa $taskDefinitionName no cluster $clusterName na revisão $revision"
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].version" --output text
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text
            } else {
                Write-Host "A tarefa $taskArn não pertence à revisão desejada."
            }
        }



    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os elementos de rede para execução da definição de tarefa de nome $taskDefinitionName"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        $subnetId1 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $subnetId2 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=default" --query "SecurityGroups[].GroupId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Executando a definição de tarefa de $taskDefinitionName no cluster $clusterName"
        aws ecs run-task --task-definition ${taskDefinitionName}:${revision} --cluster $clusterName --launch-type $launchType --network-configuration "awsvpcConfiguration={subnets=[$subnetId1,$subnetId2],securityGroups=[$sgId],assignPublicIp=ENABLED}" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a definição de tarefa $taskDefinitionName no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns[?contains(@, '$taskDefinitionArn')]" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EXCLUSION ON CLUSTER"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskDefinitionName = "taskDefinitionTest1"
$clusterName = "clusterTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a definição de tarefa $taskDefinitionName no cluster $clusterName"
    if ((aws ecs list-tasks --cluster $clusterName --family $taskDefinitionName --desired-status RUNNING --query "taskArns").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
        # aws ecs list-tasks --cluster clusterTest1 --family taskDefinitionTest1 --desired-status RUNNING --query "taskArns"
        $taskDefinitionArn = aws ecs list-tasks --cluster $clusterName --family $taskDefinitionName --desired-status RUNNING --query "taskArns[0]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Interrompendo a definição de tarefa $taskDefinitionName no cluster $clusterName"
        aws ecs stop-task --task $taskDefinitionArn --cluster $clusterName --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
    } else {Write-Output "Não existe a definição de tarefa $taskDefinitionName no cluster $clusterName"}
} else {Write-Host "Código não executado"}