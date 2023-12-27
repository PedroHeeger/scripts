#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EXECUTION ON CLUSTER EC2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskEC2Test1"
$revision = "4"
$clusterName = "clusterEC2Test1"
$launchType = "EC2"
$region = "us-east-1"
$availabilityZone1 = "us-east-1a"
$availabilityZone2 = "us-east-1b"
$accountId = "001727357081"
$taskDefinitionArn = "arn:aws:ecs:${region}:${accountId}:task/${taskName}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {  
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando uma função para executar a tarefa de nome $taskName se ela não existir no cluster $clusterName"
    function ExecutarTarefa {
        param([string]$taskName, [string]$revision, [string]$clusterName, [string]$launchType, [string]$availabilityZone1, [string]$availabilityZone2)

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
    
        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Extraindo os elementos de rede"
        # $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        # $subnetId1 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        # $subnetId2 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$availabilityZone2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        # $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=default" --query "SecurityGroups[].GroupId" --output text

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Executando a tarefa de nome $taskName no cluster $clusterName"
        # aws ecs run-task --task-definition ${taskName}:${revision} --cluster $clusterName --launch-type $launchType --network-configuration "awsvpcConfiguration={subnets=[$subnetId1,$subnetId2],securityGroups=[$sgId]}" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Executando a tarefa de nome $taskName no cluster $clusterName"
        aws ecs run-task --task-definition ${taskName}:${revision} --cluster $clusterName --launch-type $launchType --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a tarefa de nome $taskName no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns[?contains(@, '$taskDefinitionArn')]" --output text
    }

    
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a tarefa de nome $taskName no cluster $clusterName"
    if ((aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando uma lista de ARNs das revisões da tarefa de nome $taskName no cluster $clusterName"
        $taskArnsString = aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns" --output text
        $taskArnsList = $taskArnsString -split ' '

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
        foreach ($taskArn in $taskArnsList) {
            if ((aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].version" --output text) -eq $revision) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe a tarefa de nome $taskName no cluster $clusterName na revisão $revision"
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].version" --output text
                aws ecs describe-tasks --cluster $clusterName --tasks "$taskArn" --query "tasks[].taskDefinitionArn" --output text
            } else {ExecutarTarefa $taskName $revision $clusterName $launchType $availabilityZone1 $availabilityZone2}}

    } else {ExecutarTarefa $taskName $revision $clusterName $launchType $availabilityZone1 $availabilityZone2}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EXCLUSION ON CLUSTER EC2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskEC2Test1"
$clusterName = "clusterEC2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a definição de tarefa $taskName no cluster $clusterName"
    if ((aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
        # aws ecs list-tasks --cluster clusterTest1 --family taskDefinitionTest1 --desired-status RUNNING --query "taskArns"
        $taskDefinitionArn = aws ecs list-tasks --cluster $clusterName --family $taskName --desired-status RUNNING --query "taskArns[0]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Interrompendo a definição de tarefa $taskName no cluster $clusterName"
        aws ecs stop-task --task $taskDefinitionArn --cluster $clusterName --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas no cluster $clusterName"
        aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
    } else {Write-Output "Não existe a definição de tarefa $taskName no cluster $clusterName"}
} else {Write-Host "Código não executado"}