#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECR"
echo "IMAGE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
repositoryName="repository_test1"
imageTag="v1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a imagem de tag $imageTag do repositório $repositoryName"
    if [ $(aws ecr describe-images --repository-name $repositoryName --query "imageDetails[?imageTags && contains(imageTags, '$imageTag')].imageTags" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as imagens do repositório $repositoryName"
        aws ecr describe-images --repository-name $repositoryName --query "imageDetails[].imageTags" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a imagem de tag $imageTag do repositório $repositoryName"
        aws ecr batch-delete-image --repository-name $repositoryName --image-ids imageTag=$imageTag

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as imagens do repositório $repositoryName"
        aws ecr describe-images --repository-name $repositoryName --query "imageDetails[].imageTags" --output text
    else
        echo "Não existe a imagem de tag $imageTag do repositório $repositoryName"
    fi
else
    echo "Código não executado"
fi