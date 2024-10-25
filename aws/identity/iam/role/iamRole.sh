#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamRoleName="iamRoleTest"
# pathTrustPolicyDocument="G:\Meu Drive\4_PROJ\scripts\aws\.default\policy\iam\iamTrustPolicy.json"

# SERVICE:
principal="Service"
principalName="ec2.amazonaws.com"

# USER:
# principal="AWS"
# accountId="001727357081"
# iamUserName="iamUserTest"
# principalName="arn:aws:iam::${accountId}:user/${iamUserName}"

# ROLE:
# principal="AWS"
# accountId="001727357081"
# iamRoleName2="iamRoleTest2"
# principalName="arn:aws:iam::${accountId}:role/${iamRoleName2}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName"
    condition=$(aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma role $iamRoleName"
        aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a role $iamRoleName"
        aws iam create-role --role-name $iamRoleName --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"'"$principal"'": "'"$principalName"'"},
                    "Action": "sts:AssumeRole"
                }
            ]
        }' --no-cli-pager

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando a role $iamRoleName com um arquivo JSON"
        # aws iam create-role --role-name $iamRoleName --assume-role-policy-document file://$pathTrustPolicyDocument

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a role $iamRoleName"
        aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamRoleName="iamRoleTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName"
    condition=$(aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existem policies na role $iamRoleName"
        condition=$(aws iam list-attached-role-policies --role-name "$iamRoleName" --query 'AttachedPolicies[].PolicyName' --output text | wc -w)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Separando as policies da role $iamRoleName em uma lista"
            policies=($condition)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo as policies da role $iamRoleName"
            for policyName in "${policies[@]}"; do
                policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].Arn" --output text)
                aws iam detach-role-policy --role-name "$iamRoleName" --policy-arn "$policyArn"
            done
        else
            echo "Não existem policies no grupo $iamGroupName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a role $iamRoleName"
        aws iam delete-role --role-name $iamRoleName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text
    else
        echo "Não existe a role $iamRoleName"
    fi
else
    echo "Código não executado"
fi