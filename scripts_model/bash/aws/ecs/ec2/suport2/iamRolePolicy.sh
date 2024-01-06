#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE ADD POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
roleName="ecs-ec2InstanceRole"
policyName="AmazonECS_FullAccess"
policyArn="arn:aws:iam::aws:policy/AmazonECS_FullAccess"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy $policyName anexada a role de nome $roleName"
    if [ $(aws iam list-attached-role-policies --role-name "$roleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a policy $policyName anexada a role de nome $roleName"
        aws iam list-attached-role-policies --role-name "$roleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as polices anexadas a role de nome $roleName"
        aws iam list-attached-role-policies --role-name "$roleName" --query "AttachedPolicies[].PolicyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Vinculando a polciy $policyName a role de nome $roleName"
        aws iam attach-role-policy --role-name "$roleName" --policy-arn "$policyArn"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a policy $policyName anexada a role de nome $roleName"
        aws iam list-attached-role-policies --role-name "$roleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE REMOVE POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
roleName="ecs-ec2InstanceRole"
policyName="AmazonECS_FullAccess"
policyArn="arn:aws:iam::aws:policy/AmazonECS_FullAccess"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy $policyName anexada a role de nome $roleName"
    if [ $(aws iam list-attached-role-policies --role-name "$roleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as polices anexadas a role de nome $roleName"
        aws iam list-attached-role-policies --role-name "$roleName" --query "AttachedPolicies[].PolicyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a policy $policyName da role de nome $roleName"
        aws iam detach-role-policy --role-name "$roleName" --policy-arn "$policyArn"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as polices anexadas a role de nome $roleName"
        aws iam list-attached-role-policies --role-name "$roleName" --query "AttachedPolicies[].PolicyName" --output text
    else
        echo "Não existe a policy $policyName anexada a role de nome $roleName"
    fi
else
    echo "Código não executado"
fi