#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE SERVICE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
roleName="roleServiceTest"
serviceName="ec2.amazonaws.com"
# pathTrustPolicyDocument="G:\Meu Drive\4_PROJ\scripts\scripts_model\.default\aws\iamTrustPolicy.json"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role de nome $roleName"
    if [ $(aws iam list-roles --query "Roles[?RoleName=='$roleName'].RoleName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma role de nome $roleName"
        aws iam list-roles --query "Roles[?RoleName=='$roleName'].RoleName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a role de nome $roleName"
        aws iam create-role --role-name $roleName --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"Service": "'"$serviceName"'"},
                    "Action": "sts:AssumeRole"
                }
            ]
        }' --no-cli-pager

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando a role de nome $roleName com um arquivo JSON"
        # aws iam create-role --role-name $roleName --assume-role-policy-document file://$pathTrustPolicyDocument

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a role de nome $roleName"
        aws iam list-roles --query "Roles[?RoleName=='$roleName'].RoleName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE SERVICE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
roleName="roleServiceTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role de nome $roleName"
    if [ $(aws iam list-roles --query "Roles[?RoleName=='$roleName'].RoleName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Obtendo a lista de ARNs de policies anexadas à role de nome $roleName"
        attachedPolicies=$(aws iam list-attached-role-policies --role-name $roleName --query 'AttachedPolicies[*].PolicyArn' --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se a lista de ARNs de policies anexadas à role de nome $roleName está vazia"
        if [ -n "$attachedPolicies" ] && [ "$attachedPolicies" != "" ]; then

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Iterando na lista de policies"
            IFS=$'\n' # Set Internal Field Separator to newline
            for policyArn in $(echo "$attachedPolicies" | tr "\n" " "); do
                if [ "$policyArn" != "" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o nome da policy vinculada a role"
                policyName=$(aws iam list-policies --query "Policies[?Arn=='$policyArn'].PolicyName" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo a policy $policyName da role de nome $roleName"
                aws iam detach-role-policy --role-name "$roleName" --policy-arn "$policyArn"
                fi
            done
        else
            echo "Não existe policies anexadas à role de nome $roleName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a role de nome $roleName"
        aws iam delete-role --role-name $roleName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text
    else
        echo "Não existe a role de nome $roleName"
    fi
else
    echo "Código não executado"
fi