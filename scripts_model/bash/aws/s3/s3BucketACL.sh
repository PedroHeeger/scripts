#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "ACL BUCKET CHANGE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome $bucketName (Acesso Público)"
        if [[ $(aws s3api get-bucket-acl --bucket $bucketName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers' && Permission=='READ'].Permission" --output text | wc -w) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome $bucketName (Acesso Público)"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text       
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as permissões que a entidade everyone da ACL possuí no bucket de nome $bucketName"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission"
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket de nome $bucketName é o BucketOwnerPreferred"
            if [[ $(aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[?ObjectOwnership=='BucketOwnerPreferred'].ObjectOwnership" --output text | wc -w) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já foi configurado o proprietário dos objetos no bucket de nome $bucketName para BucketOwnerPreferred"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text   
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o proprietário dos objetos no bucket de nome $bucketName"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text
                
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Alterando o proprietário dos objetos no bucket de nome $bucketName para BucketOwnerPreferred"
                aws s3api put-bucket-ownership-controls --bucket $bucketName --ownership-controls="Rules=[{ObjectOwnership=BucketOwnerPreferred}]"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o proprietário dos objetos no bucket de nome $bucketName"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text 
            fi
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Concedendo permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome $bucketName"
            aws s3api put-bucket-acl --bucket $bucketName --acl public-read

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome $bucketName (Acesso Público)"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text 
        fi
    else
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "ACL BUCKET CHANGE DEFAULT"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome $bucketName (Acesso Público)"
        if [[ $(aws s3api get-bucket-acl --bucket $bucketName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers' && Permission=='READ'].Permission" --output text | wc -w) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as permissões que a entidade everyone da ACL possuí no bucket de nome $bucketName"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Restringindo as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome $bucketName"
            aws s3api put-bucket-acl --bucket $bucketName --acl private

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket de nome $bucketName é o BucketOwnerPreferred"
            if [[ $(aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[?ObjectOwnership=='BucketOwnerPreferred'].ObjectOwnership" --output text | wc -w) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o proprietário dos objetos no bucket de nome $bucketName"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text
                
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Alterando o proprietário dos objetos no bucket de nome $bucketName para BucketOwnerEnforced"
                aws s3api put-bucket-ownership-controls --bucket $bucketName --ownership-controls="Rules=[{ObjectOwnership=BucketOwnerEnforced}]"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o proprietário dos objetos no bucket de nome $bucketName"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text 
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Não foi configurado o proprietário dos objetos no bucket de nome $bucketName para BucketOwnerPreferred"
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as permissões que a entidade everyone da ACL possuí no bucket de nome $bucketName"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Não foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome $bucketName (Acesso Público)"
        fi
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi