#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE ADD POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamRoleName="iamRoleTest"
policyName="AmazonS3ReadOnlyAccess"
policyArn="arn:aws:iam::aws:policy/$policyName"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName e a policy $policyName"
    condition=$( (aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text | wc -l) -gt 0 && (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a policy $policyName anexada a role $iamRoleName"
        if [ $(aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe a policy $policyName anexada a role $iamRoleName"
            aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as polices anexadas a role $iamRoleName"
            aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[].PolicyName" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ARN da policy $policyName"
            policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Vinculando a polciy $policyName a role $iamRoleName"
            aws iam attach-role-policy --role-name "$iamRoleName" --policy-arn "$policyArn"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a policy $policyName anexada a role $iamRoleName"
            aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
    else
        echo "Não existe a role $iamRoleName ou a policy $policyName"
    fi 
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE REMOVE POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamRoleName="iamRoleTest"
policyName="AmazonS3ReadOnlyAccess"
policyArn="arn:aws:iam::aws:policy/$policyName"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName e a policy $policyName"
    condition=$( (aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text | wc -l) -gt 0 && (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a policy $policyName anexada a role $iamRoleName"
        if [ $(aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as polices anexadas a role $iamRoleName"
            aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[].PolicyName" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ARN da policy $policyName"
            policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo a policy $policyName da role $iamRoleName"
            aws iam detach-role-policy --role-name "$iamRoleName" --policy-arn "$policyArn"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as polices anexadas a role $iamRoleName"
            aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[].PolicyName" --output text
        else
            echo "Não existe a policy $policyName anexada a role $iamRoleName"
        fi
    else
        echo "Não existe a role $iamRoleName ou a policy $policyName"
    fi 
else
    echo "Código não executado"
fi