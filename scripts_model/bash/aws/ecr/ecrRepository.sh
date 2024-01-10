#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECR"
echo "REPOSITORY CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
repositoryName="repository_test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o repositório de nome $repositoryName"
    if [ $(aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o repositório de nome $repositoryName"
        aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os repositórios criados"
        aws ecr describe-repositories --query "repositories[].repositoryName" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um repositório de nome $repositoryName"
        aws ecr create-repository --repository-name $repositoryName --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o repositório de nome $repositoryName"
        aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECR"
echo "REPOSITORY EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
repositoryName="repository_test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o repositório de nome $repositoryName"
    if [ $(aws ecr describe-repositories --query "repositories[?repositoryName=='$repositoryName'].repositoryName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os repositórios criados"
        aws ecr describe-repositories --query "repositories[].repositoryName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o repositório de nome $repositoryName"
        aws ecr delete-repository --repository-name $repositoryName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os repositórios criados"
        aws ecr describe-repositories --query "repositories[].repositoryName" --output text
    else
        echo "Não existe o repositório de nome $repositoryName"
    fi
else
    echo "Código não executado"
fi