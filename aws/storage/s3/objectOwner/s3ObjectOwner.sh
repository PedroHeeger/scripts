#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "OBJECT OWNERSHIP CHANGE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
objectOwnership="BucketOwnerEnforced"  # O proprietário do bucket detém automaticamente a propriedade de todos os objetos, independentemente de quem os criou. Bloqueia todas as ACLs, e o bucket tem controle total sobre os objetos.
# objectOwnership="BucketOwnerPreferred"   # O proprietário do bucket se torna automaticamente o proprietário dos objetos, a menos que o objeto tenha uma ACL específica que defina outro proprietário.
# objectOwnership="ObjectWriter"         # O usuário que faz o upload do objeto é o proprietário, mantendo a propriedade dos objetos que eles próprios criaram.

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket $bucketName"
    condition=$(aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text | wc -w)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket $bucketName é o $objectOwnership"
        condition=$(aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[?ObjectOwnership=='$objectOwnership'].ObjectOwnership" --output text)
        if [[ -n "$condition" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já foi configurado o proprietário dos objetos no bucket $bucketName para $objectOwnership"
            aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[].ObjectOwnership" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o proprietário dos objetos no bucket $bucketName"
            aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[].ObjectOwnership" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Alterando o proprietário dos objetos no bucket $bucketName para $objectOwnership"
            aws s3api put-bucket-ownership-controls --bucket "$bucketName" --ownership-controls="Rules=[{ObjectOwnership=$objectOwnership}]"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o proprietário dos objetos no bucket $bucketName"
            aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[].ObjectOwnership" --output text
        fi
    else
        echo "Não existe o bucket $bucketName"
    fi
else
    echo "Código não executado"
fi