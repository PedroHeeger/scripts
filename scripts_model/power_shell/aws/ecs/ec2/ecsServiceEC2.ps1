#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "SERVICE EC2 CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$serviceName = "svcEC2Test1"
$clusterName = "clusterEC2Test1"
$taskName = "taskEC2Test1"
$taskVersion = "6"
$taskAmount = 2
$launchType = "EC2"
$tgName = "tgTest1"
$containerName1 = "containerTest1"
$containerPort1 = 8080

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o serviço de nome $serviceName no cluster $clusterName (Ignorando erro)..."
    $erro = "ClientException"
    if ((aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[].status" 2>&1) -match $erro)
    {$condition = 0} 
    else{$condition = (aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[].status" --output text)}
    
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o serviço de nome $serviceName no cluster $clusterName"
    $excludedStatus = "ACTIVE", 0
    if ($condition -in $excludedStatus) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName'].serviceName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os serviços no cluster $clusterName"
        aws ecs list-services --cluster $clusterName --query "serviceArns" --output text

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Extraindo o ARN do target group $tgName"
        # $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text
   
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs create-service --cluster $clusterName --service-name $serviceName --task-definition "${taskName}:${taskVersion}" --desired-count $taskAmount --launch-type $launchType --scheduling-strategy REPLICA --deployment-configuration "minimumHealthyPercent=25,maximumPercent=200" --no-cli-pager

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando o serviço de nome $serviceName no cluster $clusterName"
        # aws ecs create-service --cluster $clusterName --service-name $serviceName --task-definition "${taskName}:${taskVersion}" --desired-count $taskAmount --launch-type $launchType --scheduling-strategy REPLICA --deployment-configuration "minimumHealthyPercent=25,maximumPercent=200" --load-balancers "targetGroupArn=$tgArn,containerName=$containerName1,containerPort=$containerPort1" --placement-constraints "type=distinctInstance" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName'].serviceName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "SERVICE EC2 EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$serviceName = "svcEC2Test1"
$clusterName = "clusterEC2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o serviço de nome $serviceName no cluster $clusterName (Ignorando erro)..."
    $erro = "InvalidParameterException"
    if ((aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[].status" 2>&1) -match $erro)
    {$condition = 0} 
    else{$condition = (aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[].status" --output text)}
    
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o serviço de nome $serviceName no cluster $clusterName"
    $excludedStatus = "ACTIVE", 0
    if ($condition -in $excludedStatus) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os serviços criados no $clusterName"
        aws ecs list-services --cluster $clusterName --query "serviceArns" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Atualizando a quantidade desejada de tarefas do serviço de nome $serviceName para 0"
        aws ecs update-service --cluster $clusterName --service $serviceName --desired-count 0 --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o serviço de nome $serviceName do cluster $clusterName"
        aws ecs delete-service --cluster $clusterName --service $serviceName --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os serviços criados no $clusterName"
        aws ecs list-services --cluster $clusterName --query "serviceArns" --output text
    } else {Write-Output "Não existe o cluster de nome $clusterName"}
} else {Write-Host "Código não executado"}