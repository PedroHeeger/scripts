#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "SERVICE FARGATE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$serviceName = "svcFargateTest1"
$clusterName = "clusterFargateTest1"
$taskName = "taskFargateTest1"
$taskVersion = "10"
$taskAmount = 2
$launchType = "FARGATE"
$az1 = "us-east-1a"
$az2 = "us-east-1b"
$tgName = "tgTest1"
$containerName1 = "containerTest1"
$containerPort1 = 8080

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "Verificando se existe o serviço de nome $serviceName no cluster $clusterName (Ignorando erro)..."
    $erro = "ClientException"
    if ((aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName' && status=='ACTIVE'].serviceName" 2>&1) -match $erro)
    {$condition = 0} 
    else{$condition = (aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName' && status=='ACTIVE'].serviceName").Count}
    
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o serviço de nome $serviceName no cluster $clusterName"
    if ($condition -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName'].serviceName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os serviços no cluster $clusterName"
        aws ecs list-services --cluster $clusterName --query "serviceArns" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os elementos de rede"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        $subnetId1 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$az1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $subnetId2 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$az2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=default" --query "SecurityGroups[].GroupId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do target group $tgName"
        $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs create-service --cluster $clusterName --service-name $serviceName --task-definition "${taskName}:${taskVersion}" --desired-count $taskAmount --launch-type $launchType --platform-version "LATEST" --scheduling-strategy REPLICA --deployment-configuration minimumHealthyPercent=25,maximumPercent=200 --network-configuration "awsvpcConfiguration={subnets=[$subnetId1,$subnetId2],securityGroups=[$sgId],assignPublicIp=ENABLED}" --no-cli-pager

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando o serviço de nome $serviceName no cluster $clusterName com load balancer"
        # aws ecs create-service --cluster $clusterName --service-name $serviceName --task-definition "${taskName}:${taskVersion}" --desired-count $taskAmount --launch-type $launchType --platform-version "LATEST" --scheduling-strategy REPLICA --deployment-configuration minimumHealthyPercent=25,maximumPercent=200 --network-configuration "awsvpcConfiguration={subnets=[$subnetId1,$subnetId2],securityGroups=[$sgId],assignPublicIp=ENABLED}" --load-balancers targetGroupArn=$tgArn,containerName=$containerName1,containerPort=$containerPort1 --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o serviço de nome $serviceName no cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[?serviceName=='$serviceName'].serviceName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "SERVICE FARGATE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$serviceName = "svcFargateTest1"
$clusterName = "clusterFargateTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cluster de nome $clusterName"
    if ((aws ecs describe-services --cluster $clusterName --services $serviceName --query "services[].serviceName").Count -gt 1) {
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