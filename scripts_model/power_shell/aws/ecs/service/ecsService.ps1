#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "SERVICE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$serviceName = "serviceTest"
$clusterName = "clusterTest1"
$taskDefinitionName = "taskDefinitionTest"
$revision = "2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o serviço de nome $serviceName"
    if ((aws ecs describe-services --cluster $clusterName --query "services[?serviceName=='$serviceName']").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o serviço de nome $serviceName"
        aws ecs describe-services --cluster $clusterName --query "services[?serviceName=='$serviceName']" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os serviços do cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --query "services[].serviceName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o serviço de nome $serviceName"
        aws ecs create-service --cluster $clusterName --service-name $serviceName --task-definition $taskDefinitionName --desired-count 1

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o serviço de nome $serviceName"
        aws ecs describe-services --cluster $clusterName --query "services[?serviceName=='$serviceName']" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "SERVICE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$serviceName = "serviceTest"
$clusterName = "clusterTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o serviço de nome $serviceName"
    if ((aws ecs describe-services --cluster $clusterName --query "services[?serviceName=='$serviceName']").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os serviços do cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --query "services[].serviceName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o serviço de nome $serviceName"
        aws ecs delete-service --cluster $clusterName --service $serviceName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os serviços do cluster $clusterName"
        aws ecs describe-services --cluster $clusterName --query "services[].serviceName" --output text
    } else {Write-Output "Não existe o serviço de nome $serviceName"}
} else {Write-Host "Código não executado"}