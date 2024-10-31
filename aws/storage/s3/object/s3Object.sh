#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "OBJECT CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
objectName="objTest.jpg"
filePath="G:/Meu Drive/4_PROJ/scripts/aws/storage/s3/object"
fileName="objTest.jpg"
storageClass="STANDARD"
contentType="image/jpg"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket $bucketName"
    condition=$(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o objeto $objectName no bucket $bucketName"
        condition=$(aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text | wc -w)
        if [[ ${#condition[@]} -gt 0 && "$condition" != "None" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o objeto $objectName no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a URL do objeto $objectName"
            echo "https://$bucketName.s3.amazonaws.com/$objectName"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o objeto $objectName no bucket $bucketName"
            aws s3api put-object --bucket $bucketName --key $objectName --body "$filePath/$fileName" --storage-class $storageClass --content-type $contentType
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o objeto $objectName no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a URL do objeto $objectName"
            echo "https://$bucketName.s3.amazonaws.com/$objectName"
        fi
    else
        echo "Não existe o bucket $bucketName"
    fi
else
    echo "Código não executado"
fi




#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "OBJECT EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
objectName="objTest.jpg"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket $bucketName"
    condition=$(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o objeto $objectName no bucket $bucketName"
        condition=$(aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text | wc -w)
        if [[ ${#condition[@]} -gt 0 && "$condition" != "None" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o objeto $objectName no bucket $bucketName"
            aws s3api delete-object --bucket $bucketName --key $objectName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
        else
            echo "Não existe o objeto $objectName no bucket $bucketName"
        fi
    else
        echo "Não existe o bucket $bucketName"
    fi
else
    echo "Código não executado"
fi