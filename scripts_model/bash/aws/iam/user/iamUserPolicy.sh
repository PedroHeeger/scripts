#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER ADD POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
policyName="AmazonS3FullAccess"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy $policyName no usuário $iamUserName"
    if [[ $(aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a policy $policyName no usuário $iamUserName"
        aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as policies do usuário $iamUserName"
        aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].Arn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Adicionando a policy $policyName ao usuário $iamUserName"
        aws iam attach-user-policy --user-name $iamUserName --policy-arn $policyArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a policy $policyName do usuário $iamUserName"
        aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER REMOVE POLICY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
policyName="AmazonS3FullAccess"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy $policyName no usuário $iamUserName"
    if [[ $(aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as policies do usuário $iamUserName"
        aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].Arn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a policy $policyName do usuário $iamUserName"
        aws iam detach-user-policy --user-name $iamUserName --policy-arn $policyArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as policies do usuário $iamUserName"
        aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text
    else
        echo "Não existe a policy $policyName no usuário $iamUserName"
    fi
else
    echo "Código não executado"
fi