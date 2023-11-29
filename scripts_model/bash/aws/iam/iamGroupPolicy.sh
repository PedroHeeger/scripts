#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM GROUP ADD POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"
policyName="AdministratorAccess"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy $policyName no grupo $iamGroupName"
    if [ $(aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a policy $policyName no grupo $iamGroupName"
        aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as policies do grupo $iamGroupName"
        aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[].PolicyName" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Adicionando a policy $policyName ao grupo $iamGroupName"
        aws iam attach-group-policy --group-name $iamGroupName --policy-arn $policyArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a policy $policyName do grupo $iamGroupName"
        aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM GROUP REMOVE POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamGroupName="iamGroupTest"
policyName="AdministratorAccess"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy $policyName no grupo $iamGroupName"
    if [ "$(aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l)" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as policies do grupo $iamGroupName"
        aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[].PolicyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a policy $policyName do grupo $iamGroupName"
        aws iam detach-group-policy --group-name $iamGroupName --policy-arn $policyArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as policies do grupo $iamGroupName"
        aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[].PolicyName" --output text
    else
        echo "Não existe a policy $policyName no grupo $iamGroupName"
    fi
else
    echo "Código não executado"
fi