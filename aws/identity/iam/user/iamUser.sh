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
    echo "Verificando se existe o usuário do IAM $iamUserName"
    condition=$(aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe um usuário do IAM $iamUserName"
        aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o usuário do IAM $iamUserName"
        aws iam create-user --user-name $iamUserName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um perfil de login do usuário do IAM $iamUserName"
        aws iam create-login-profile --user-name $iamUserName --password $userPassword

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o usuário do IAM $iamUserName"
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
    echo "Verificando se existe o usuário do IAM $iamUserName"
    condition=$(aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando quais grupos o usuário do IAM $iamUserName está inserido"
        condition=$(aws iam list-groups-for-user --user-name $iamUserName --query 'Groups[].GroupName' --output text | wc -w)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Separando os grupos do usuário do IAM $iamUserName em uma lista"
            groups=($condition)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o usuário do IAM $iamUserName dos grupos"
            for $iamGroupName in "${groups[@]}"; do
                aws iam remove-user-from-group --group-name "$iamGroupName" --user-name "$iamUserName"
            done
        else
            echo "Não existem grupos que o usuário do IAM $iamUserName faça parte"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existem policies vinculadas ao usuário do IAM $iamUserName"
        condition=$(aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text | wc -w)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Separando as policies do usuário do IAM $iamUserName em uma lista"
            policies=($condition)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo as policies do usuário do IAM $iamUserName"
            for policyName in "${policies[@]}"; do
                policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].Arn" --output text)
                aws iam detach-user-policy --user-name "$iamUserName" --policy-arn "$policyArn"    
            done
        else
            echo "Não existem policies vinculadas ao usuário do IAM $iamUserName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o perfil de login do usuário do IAM $iamUserName"
        aws iam delete-login-profile --user-name $iamUserName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o usuário do IAM $iamUserName"
        aws iam delete-user --user-name $iamUserName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text
    else
        echo "Não existe o usuário do IAM $iamUserName"
    fi
else
    echo "Código não executado"
fi