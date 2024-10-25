#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER ADD GROUP"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"
iamUserName="iamUserTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o grupo $iamGroupName e o usuário do IAM $iamUserName"
    condition=$( (aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text | wc -l) -gt 0 && (aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o usuário do IAM $iamUserName no grupo $iamGroupName"
        condition=$(aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o usuário do IAM $iamUserName no grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os usuários do IAM do grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[].UserName" --output text
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Adicionando o usuário do IAM $iamUserName ao grupo $iamGroupName"
            aws iam add-user-to-group --user-name $iamUserName --group-name $iamGroupName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o usuário $iamUserName no grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text
        fi
    else
        echo "Não existe o grupo $iamGroupName ou o usuário do IAM $iamUserName"
    fi 
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER REMOVE GROUP"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"
iamUserName="iamUserTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o grupo $iamGroupName e o usuário do IAM $iamUserName"
    condition=$( (aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text | wc -l) -gt 0 && (aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o usuário do IAM $iamUserName no grupo $iamGroupName"
        condition=$(aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os usuários do IAM do grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[].UserName" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o usuário do IAM $iamUserName do grupo $iamGroupName"
            aws iam remove-user-from-group --user-name $iamUserName --group-name $iamGroupName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os usuários do IAM do grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[].UserName" --output text
        else
            echo "Não existe o usuário do IAM $iamUserName no grupo $iamGroupName"
        fi
    else
        echo "Não existe o grupo $iamGroupName ou o usuário do IAM $iamUserName"
    fi        
else
    echo "Código não executado"
fi