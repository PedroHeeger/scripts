#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM ROLE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
roleName="roleNameTest"
pathTrustPolicyDocument="G:\Meu Drive\4_PROJ\scripts\scripts_model\.default\aws\iamTrustPolicy.json"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role de nome $roleName"
    if [ $(aws iam list-roles --query "Roles[?RoleName=='$roleName'].RoleName" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma role de nome $roleName"
        aws iam list-roles --query "Roles[?RoleName=='$roleName'].RoleName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a role de nome $roleName"
        aws iam create-role --role-name "$roleName" --assume-role-policy-document "{
            \"Version\": \"2012-10-17\",
            \"Statement\": [
                {
                    \"Effect\": \"Allow\",
                    \"Principal\": {\"AWS\": \"arn:aws:iam::001727357081:user/${iamUserName}\"},
                    \"Action\": \"sts:AssumeRole\"
                }
            ]
        }"

        # Descomente a seção abaixo se quiser criar a role usando um arquivo JSON
        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando a role de nome $roleName com um arquivo JSON"
        # aws iam create-role --role-name "$roleName" --assume-role-policy-document file://"$pathTrustPolicyDocument"
        
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
echo "IAM ROLE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iam_user_name="iamUserTest"
role_name="roleNameTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
# if [ "${resposta,,}" == 'y' ]; then
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role de nome $role_name"
    if [ $(aws iam list-roles --query "Roles[?RoleName=='$role_name'].RoleName" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a role de nome $role_name"
        aws iam delete-role --role-name "$role_name"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Não existe a role de nome $role_name"
    fi
else
    echo "Código não executado"
fi