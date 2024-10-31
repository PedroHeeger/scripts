#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "MODIFY BUCKET PUBLIC ACCESS"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
blockPublicAcls="true"          # Impede que qualquer nova ACL pública seja aplicada a objetos no bucket. Qualquer ACL pública existente funciona.
ignorePublicAcls="true"         # Faz com que o bucket ignore todas as ACLs públicas existentes, independentemente de quando foram criadas. Mas permite a criação delas.
blockPublicPolicy="true"        # Impede que novas políticas públicas (Bucket Policies) sejam aplicadas ao bucket. As existentes continuarão funcionando.
restrictPublicBuckets="true"    # Restringe completamente o acesso público ao bucket, tanto por ACLs quanto por Bucket Policies, tanto novas como existentes.

# blockPublicAcls="false"
# ignorePublicAcls="false"
# blockPublicPolicy="true"
# restrictPublicBuckets="false"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket $bucketName"
    condition=$(aws s3api list-buckets --region "$region" --query "Buckets[?Name=='$bucketName'].Name" --output text)
    if [[ -n "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Definindo a query das configurações de bloqueio de acesso público"
        if [[ "$blockPublicAcls" == "true" ]]; then queryBpa="PublicAccessBlockConfiguration.BlockPublicAcls"; else queryBpa="!(PublicAccessBlockConfiguration.BlockPublicAcls)"; fi
        if [[ "$ignorePublicAcls" == "true" ]]; then queryIpa="PublicAccessBlockConfiguration.IgnorePublicAcls"; else queryIpa="!(PublicAccessBlockConfiguration.IgnorePublicAcls)"; fi
        if [[ "$blockPublicPolicy" == "true" ]]; then queryBpp="PublicAccessBlockConfiguration.BlockPublicPolicy"; else queryBpp="!(PublicAccessBlockConfiguration.BlockPublicPolicy)"; fi
        if [[ "$restrictPublicBuckets" == "true" ]]; then queryRpb="PublicAccessBlockConfiguration.RestrictPublicBuckets"; else queryRpb="!(PublicAccessBlockConfiguration.RestrictPublicBuckets)"; fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se as configurações de bloqueio de acesso público do bucket $bucketName estão conforme definidas nas variáveis"
        condition=$(aws s3api get-public-access-block --bucket "$bucketName" --query "$queryBpa && $queryIpa && $queryBpp && $queryRpb" --output text)
        if [[ "$condition" == "true" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "As configurações de bloqueio de acesso público do bucket $bucketName estão conforme definição nas variáveis"
            aws s3api get-public-access-block --bucket "$bucketName" --query "PublicAccessBlockConfiguration"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de bloqueio de acesso público do bucket $bucketName"
            aws s3api get-public-access-block --bucket "$bucketName" --query "PublicAccessBlockConfiguration"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Alterando as configurações de bloqueio de acesso público do bucket $bucketName"
            aws s3api put-public-access-block --bucket "$bucketName" --public-access-block-configuration "BlockPublicAcls=$blockPublicAcls,IgnorePublicAcls=$ignorePublicAcls,BlockPublicPolicy=$blockPublicPolicy,RestrictPublicBuckets=$restrictPublicBuckets"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a configuração de bloqueio de acesso público do bucket $bucketName"
            aws s3api get-public-access-block --bucket "$bucketName" --query "PublicAccessBlockConfiguration"
        fi
    else
        echo "Não existe o bucket $bucketName"
    fi
else
    echo "Código não executado"
fi