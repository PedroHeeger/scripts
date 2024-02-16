#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "CLUSTER EC2 CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clusterName = "clusterEC2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cluster de nome $clusterName (Ignorando erro)..."
    $erro = "ResourceNotFoundException"
    if ((aws ecs describe-clusters --clusters $clusterName --query "clusters[].status" 2>&1) -match $erro)
    {$condition = 0} 
    else {$condition = (aws ecs describe-clusters --clusters $clusterName --query "clusters[].status" --output text)}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cluster de nome $clusterName"
    $excludedStatus = "ACTIVE", "CREATING", 0
    if ($condition -in $excludedStatus) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterName --query "clusters[].clusterName[]" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um cluster de nome $clusterName"
        aws ecs create-cluster --cluster-name $clusterName --settings "name=containerInsights,value=enabled" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterName --query "clusters[].clusterName[]" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "CLUSTER EC2 EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clusterName = "clusterEC2Test1"
$logGroupName = "/aws/ecs/containerinsights/${clusterName}/performance"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cluster de nome $clusterName (Ignorando erro)..."
    $erro = "ResourceNotFoundException"
    if ((aws ecs describe-clusters --clusters $clusterName --query "clusters[].status" 2>&1) -match $erro)
    {$condition = 0} 
    else {$condition = (aws ecs describe-clusters --clusters $clusterName --query "clusters[].status" --output text)}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cluster de nome $clusterName"
    $excludedStatus = "ACTIVE", "CREATING", 0
    if ($condition -in $excludedStatus) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o cluster de nome $clusterName"
        aws ecs delete-cluster --cluster $clusterName --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o log group de nome $logGroupName"
        if ((aws logs describe-log-groups --query "logGroups[?logGroupName=='$logGroupName'].logGroupName").Count -gt 1) {       
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o log group de nome $logGroupName"
            aws logs delete-log-group --log-group-name $logGroupName
        } else {Write-Output "Não existe o log group de nome $logGroupName"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    } else {Write-Output "Não existe o cluster de nome $clusterName"}
} else {Write-Host "Código não executado"}