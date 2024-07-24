#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "OBJECT CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
objectName="objTest.jpg"
filePath="G:/Meu Drive/4_PROJ/scripts/scripts_model/power_shell/aws/s3"
fileName="objTest.jpg"
storageClass="STANDARD"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o objeto de nome $objectName no bucket $bucketName"
        if [[ $(aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text | wc -w) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o objeto de nome $objectName no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a URL do objeto de nome $objectName"
            echo "https://$bucketName.s3.amazonaws.com/$objectName"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o objeto de nome $objectName no bucket $bucketName"
            aws s3api put-object --bucket $bucketName --key $objectName --body "$filePath/$fileName" --storage-class $storageClass
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o objeto de nome $objectName no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a URL do objeto de nome $objectName"
            echo "https://$bucketName.s3.amazonaws.com/$objectName"
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
    echo "Verificando se existe o bucket de nome $bucketName"
    if [[ $(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o objeto de nome $objectName no bucket $bucketName"
        if [[ $(aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text | wc -w) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o objeto de nome $objectName no bucket $bucketName"
            aws s3api delete-object --bucket $bucketName --key $objectName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
        else
            echo "Não existe o objeto de nome $objectName no bucket $bucketName"
        fi
    else
        echo "Não existe o bucket de nome $bucketName"
    fi
else
    echo "Código não executado"
fi