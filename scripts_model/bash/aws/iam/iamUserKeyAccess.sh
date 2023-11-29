#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER KEY ACCESS CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
keyAccessFile="keyAccessTest.json"
keyAccessPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\bash\.default\secrets"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe chave de acesso para o usuário do IAM $iamUserName"
    if [ $(aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma chave de acesso criada para o usuário do IAM $iamUserName"
        aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as chaves de acesso criadas do usuário do IAM $iamUserName"
        aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata"
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando uma chave de acesso para o usuário do IAM $iamUserName"
        aws iam create-access-key --user-name $iamUserName > "$keyAccessPath/$keyAccessFile"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as chaves de acesso do usuário do IAM $iamUserName"
        aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER KEY ACCESS EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
keyAccessFile="keyAccessTest.json"
keyAccessPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\bash\.default\secrets"
# keyAccessId="AKIAQCPZALZ6WNXS6ZEJ"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe chave de acesso para o usuário do IAM $iamUserName"
    if [ $(aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as chaves de acesso cridadas do usuário do IAM $iamUserName"
        aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo Id da primeira chave de acesso existente"
        keyAccessId=$(aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[0].AccessKeyId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a chave de acesso do usuário do IAM $iamUserName"
        aws iam delete-access-key --user-name $iamUserName --access-key-id $keyAccessId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o arquivo de chave de acesso $keyAccessFile"
        if [ -f "$keyAccessPath/$keyAccessFile" ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o arquivo de chave de acesso $keyAccessFile"
            rm "$keyAccessPath/$keyAccessFile"
        else
            echo "Não existe o arquivo de chave de acesso $keyAccessFile"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as chaves de acesso cridadas do usuário do IAM $iamUserName"
        aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata"
    else
        echo "Não existe o usuário do IAM de nome $iamUserName"
    fi
else
    echo "Código não executado"
fi