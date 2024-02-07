#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECR"
Write-Output "REPOSITORY CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$repositoryName = "repository_test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o repositório de nome $repositoryName"
    if ((aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o repositório de nome $repositoryName"
        aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os repositórios criados"
        aws ecr describe-repositories --query "repositories[].repositoryName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um repositório de nome $repositoryName"
        aws ecr create-repository --repository-name $repositoryName --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o repositório de nome $repositoryName"
        aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECR"
Write-Output "REPOSITORY EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$repositoryName = "repository_test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o repositório de nome $repositoryName"
    if ((aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os repositórios criados"
        aws ecr describe-repositories --query "repositories[].repositoryName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a imagem do repositório de nome $repositoryName"
        if ((aws ecr describe-images --repository-name $repositoryName --query "imageDetails[].imageTags").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Obtendo a lista de tags da imagem do repositório de nome $repositoryName"
            $imageTags = aws ecr describe-images --repository-name $repositoryName --query "imageDetails[].imageTags" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Iterando na lista de tags"
            foreach ($imageTag in $imageTags.Split()) {
                if ($imageTag -ne "") {
                #   Write-Output "-----//-----//-----//-----//-----//-----//-----"
                #   Write-Output "Extraindo a tag da imagem"
                #   $tag = aws ecr describe-images --repository-name $repositoryName --query "imageDetails[?imageTags=='$imageTag'].imageTags" --output text
  
                  Write-Output "-----//-----//-----//-----//-----//-----//-----"
                  Write-Output "Removendo a imagem de tag $imageTag do repositório de nome $repositoryName"
                  aws ecr batch-delete-image --repository-name $repositoryName --image-ids imageTag=$imageTag
                }
            }
        } else {Write-Output "Não existe imagens no repositório $repositoryName"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o repositório de nome $repositoryName"
        aws ecr delete-repository --repository-name $repositoryName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os repositórios criados"
        aws ecr describe-repositories --query "repositories[].repositoryName" --output text
    } else {Write-Output "Não existe o repositório de nome $repositoryName"}
} else {Write-Host "Código não executado"}