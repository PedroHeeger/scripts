#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECR"
Write-Output "IMAGE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$repositoryName = "repository_test1"
$imageTag = "v1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a image de tag $imageTag do repositório $repositoryName"
    if ((aws ecr describe-images --repository-name $repositoryName --query "imageDetails[?contains(imageTags, '$imageTag')].imageTags").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as imagens do repositório $repositoryName"
        aws ecr describe-images --repository-name $repositoryName --query "imageDetails[].imageTags" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a image de tag $imageTag do repositório $repositoryName"
        aws ecr batch-delete-image --repository-name $repositoryName --image-ids imageTag=$imageTag

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as imagens do repositório $repositoryName"
        aws ecr describe-images --repository-name $repositoryName --query "imageDetails[].imageTags" --output text
    } else {Write-Output "Não existe a image de tag $imageTag do repositório $repositoryName"}
} else {Write-Host "Código não executado"}