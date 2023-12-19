#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "CLUSTER FARGATE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clusterName = "clusterFargateTest1"
$capacityProviderName = "FARGATE"
$region = "us-east-1"
$accountId = "001727357081"
$clusterArn = "arn:aws:ecs:${region}:${accountId}:cluster/${clusterName}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cluster de nome $clusterName"
    if ((aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
        # Split-Path (aws ecs list-clusters --query "clusterArns[?clusterArns==`"${clusterArn}`"]" --output text) -Leaf
        # aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um cluster de nome $clusterName"
        aws ecs create-cluster --cluster-name $clusterName --settings "name=containerInsights,value=enabled" --capacity-providers $capacityProviderName --default-capacity-provider-strategy "capacityProvider=$capacityProviderName,weight=1" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o cluster de nome $clusterName"
        aws ecs describe-clusters --clusters $clusterArn --query "clusters[].clusterName[]" --output text
        # Split-Path (aws ecs list-clusters --query "clusterArns[?clusterArns==`"${clusterArn}`"]" --output text) -Leaf
        # aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "CLUSTER FARGATE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clusterName = "clusterFargateTest1"
$region = "us-east-1"
$accountId = "001727357081"
$clusterArn = "arn:aws:ecs:${region}:${accountId}:cluster/${clusterName}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o cluster de nome $clusterName"
    if ((aws ecs list-clusters --query "clusterArns[?contains(@, '${clusterArn}')]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o cluster de nome $clusterName"
        aws ecs delete-cluster --cluster $clusterName --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todos os clusters criados"
        aws ecs list-clusters --query clusterArns[] --output text
    } else {Write-Output "Não existe o cluster de nome $clusterName"}
} else {Write-Host "Código não executado"}