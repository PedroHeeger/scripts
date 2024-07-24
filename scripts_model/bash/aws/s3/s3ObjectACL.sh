#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "ACL OBJECT CHANGE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
objectName="objTest1.txt"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre o objeto de nome $objectName (Acesso Público)"
        if [[ $(aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers' && Permission=='READ'].Permission" --output text | wc -w) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já foi configurado as permissões de leitura para entidade everyone da ACL sobre o objeto de nome $objectName (Acesso Público)"
            aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as permissões que a entidade everyone da ACL possuí no objeto de nome $objectName"
            aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Concedendo permissões de leitura para entidade everyone da ACL sobre o objeto de nome $objectName (Acesso Público)"
            aws s3api put-object-acl --bucket $bucketName --key $objectName --acl public-read

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de permissões de leitura para entidade everyone da ACL sobre o objeto de nome $objectName (Acesso Público)"
            aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text
        fi
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "ACL OBJECT CHANGE DEFAULT"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
objectName="objTest1.txt"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre o objeto de nome $objectName (Acesso Público)"
        if [[ $(aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers' && Permission=='READ'].Permission" --output text | wc -w) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as permissões que a entidade everyone da ACL possuí no objeto de nome $objectName"
            aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Restringindo permissões de leitura para entidade everyone da ACL sobre o objeto de nome $objectName (Acesso Público)"
            aws s3api put-object-acl --bucket $bucketName --key $objectName --acl private

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as permissões que a entidade everyone da ACL possuí no objeto de nome $objectName"
            aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Não foi configurado permissões de leitura para entidade everyone da ACL sobre o objeto de nome $objectName (Acesso Público)"
        fi
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi