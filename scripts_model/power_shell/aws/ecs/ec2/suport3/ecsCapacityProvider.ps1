#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "CAPACITY PROVIDER CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$capacityProviderName = "capacityProviderTest1"
$asgName = "asgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o fornecedor de capacidade de nome $capacityProviderName"
    if ((aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o fornecedor de capacidade de nome $capacityProviderName"
        aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os fornecedores de capacidade existentes"
        aws ecs describe-capacity-providers --query "capacityProviders[].name[]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do auto scaling group $asgName"
        $asgArn = aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?AutoScalingGroupName=='$asgName'].AutoScalingGroupARN" --output text    
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um fornecedor de capacidade de nome $capacityProviderName"
        aws ecs create-capacity-provider --name $capacityProviderName --auto-scaling-group-provider "autoScalingGroupArn=$asgArn,managedScaling={status=ENABLED,targetCapacity=100},managedTerminationProtection=DISABLED" --no-cli-pager
      
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o fornecedor de capacidade de nome $capacityProviderName"
        aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "CAPACITY PROVIDER EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$capacityProviderName = "capacityProviderTest1"
# $clusterName = "clusterEC2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o fornecedor de capacidade de nome $capacityProviderName"
    if ((aws ecs describe-capacity-providers --query "capacityProviders[?name=='$capacityProviderName'].name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os fornecedores de capacidade existentes"
        aws ecs describe-capacity-providers --query "capacityProviders[].name[]" --output text

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Removendo o fornecedor de capacidade de nome $capacityProviderName do cluster $clusterName"
        # aws ecs put-cluster-capacity-providers --cluster cluster_name --capacity-providers

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o fornecedor de capacidade de nome $capacityProviderName"
        aws ecs delete-capacity-provider --capacity-provider $capacityProviderName --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os fornecedores de capacidade existentes"
        aws ecs describe-capacity-providers --query "capacityProviders[].name[]" --output text
    } else {Write-Output "Não existe o fornecedor de capacidade de nome $capacityProviderName"}
} else {Write-Host "Código não executado"}