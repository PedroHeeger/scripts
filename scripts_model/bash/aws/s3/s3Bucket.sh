#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "BUCKET CREATION"

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
        echo "Já existe o bucket de nome $bucketName"
        aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os buckets na região $region"
        aws s3api list-buckets --region $region --query "Buckets[].Name" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o bucket de nome $bucketName"
        aws s3api create-bucket --bucket $bucketName --region $region

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o bucket de nome $bucketName"
        aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text
    fi
else
    echo "Código não executado"
fi




#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "BUCKET EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os buckets na região $region"
        aws s3api list-buckets --region $region --query "Buckets[].Name" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se há objetos no bucket de nome $bucketName e removendo caso haja"
        objects=$(aws s3api list-object-versions --bucket $bucketName --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)

        objectCount=$(echo "$objects" | grep -o '"Key":' | wc -l)
        if [[ "$objectCount" -gt 0 ]]; then
            echo "$objects" | grep -o '"Key": "[^"]*" "VersionId": "[^"]*"' | while read -r line; do
                key=$(echo "$line" | grep -o '"Key": "[^"]*"' | sed 's/"Key": "\(.*\)"/\1/')
                versionId=$(echo "$line" | grep -o '"VersionId": "[^"]*"' | sed 's/"VersionId": "\(.*\)"/\1/')
                aws s3api delete-object --bucket $bucketName --key "$key" --version-id "$versionId"
            done
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o bucket de nome $bucketName"
        aws s3api delete-bucket --bucket $bucketName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os buckets na região $region"
        aws s3api list-buckets --region $region --query "Buckets[].Name" --output text
    else
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi