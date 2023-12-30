#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
userPassword="SenhaTest123"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o usuário do IAM de nome $iamUserName"
    if [ $(aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe um usuário do IAM de nome $iamUserName"
        aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o usuário do IAM de nome $iamUserName"
        aws iam create-user --user-name $iamUserName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um perfil de login do usuário do IAM de nome $iamUserName"
        aws iam create-login-profile --user-name $iamUserName --password $userPassword

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o usuário do IAM de nome $iamUserName"
        aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o usuário do IAM de nome $iamUserName"
    if [ $(aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o perfil de login do usuário do IAM de nome $iamUserName"
        aws iam delete-login-profile --user-name $iamUserName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o usuário do IAM de nome $iamUserName"
        aws iam delete-user --user-name $iamUserName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text
    else
        echo "Não existe o usuário do IAM de nome $iamUserName"
    fi
else
    echo "Código não executado"
fi