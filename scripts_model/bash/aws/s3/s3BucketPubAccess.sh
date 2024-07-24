#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "ENABLE BUCKET PUBLIC ACCESS"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se a configuração de bloqueio de acesso público do bucket de nome $bucketName está desativada"
        publicAccessBlockStatus=$(aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration.BlockPublicAcls,PublicAccessBlockConfiguration.IgnorePublicAcls,PublicAccessBlockConfiguration.RestrictPublicBuckets" --output text)
        if [[ "$publicAccessBlockStatus" == "false false false" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já está desativada a configuração de bloqueio de acesso público do bucket de nome $bucketName"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de bloqueio de acesso público do bucket de nome $bucketName"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration"
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Desativando a configuração de bloqueio de acesso público do bucket de nome $bucketName"
            aws s3api put-public-access-block --bucket $bucketName --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=true,RestrictPublicBuckets=false"
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de bloqueio de acesso público do bucket de nome $bucketName"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration"
        fi
    else
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi




#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "DISABLE BUCKET PUBLIC ACCESS"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se a configuração de bloqueio de acesso público do bucket de nome $bucketName está desativada"
        publicAccessBlockStatus=$(aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration.BlockPublicAcls,PublicAccessBlockConfiguration.IgnorePublicAcls,PublicAccessBlockConfiguration.RestrictPublicBuckets" --output text)
        if [[ "$publicAccessBlockStatus" == "false false false" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de bloqueio de acesso público do bucket de nome $bucketName"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration"
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Ativando a configuração de bloqueio de acesso público do bucket de nome $bucketName"
            aws s3api put-public-access-block --bucket $bucketName --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de bloqueio de acesso público do bucket de nome $bucketName"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration"
        else
            echo "Não está desativada a configuração de bloqueio de acesso público do bucket de nome $bucketName"
        fi
    else
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi