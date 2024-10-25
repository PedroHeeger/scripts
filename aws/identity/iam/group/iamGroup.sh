#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o grupo $iamGroupName"
    condition=$(aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o grupo $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o grupo $iamGroupName"
        aws iam create-group --group-name $iamGroupName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o grupo $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM GROUP EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o grupo $iamGroupName"
    condition=$(aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existem usuários do IAM no grupo $iamGroupName"
        condition=$(aws iam get-group --group-name "$iamGroupName" --query "Users[].UserName" --output text | wc -w)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Separando os usuários do grupo $iamGroupName em uma lista"
            users=($condition)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo os usuários do grupo $iamGroupName"
            for user in "${users[@]}"; do
                aws iam remove-user-from-group --group-name "$iamGroupName" --user-name "$user"
            done
        else
            echo "Não existem usuários do IAM no grupo $iamGroupName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existem policies no grupo $iamGroupName"
        condition=$(aws iam list-attached-group-policies --group-name "$iamGroupName" --query "AttachedPolicies[].PolicyName" --output text | wc -w)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Separando as policies do grupo $iamGroupName em uma lista"
            policies=($condition)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo as policies do grupo $iamGroupName"
            for policyName in "${policies[@]}"; do
                policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].Arn" --output text)
                aws iam detach-group-policy --group-name "$iamGroupName" --policy-arn "$policyArn"
            done
        else
            echo "Não existem policies no grupo $iamGroupName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o grupo $iamGroupName"
        aws iam delete-group --group-name $iamGroupName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text
    else
        echo "Não existe o grupo $iamGroupName"
    fi
else
    echo "Código não executado"
fi