#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "ACL BUCKET CHANGE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
# CanonicalUser = Usuário que criou o bucket, com controle total e acesso garantido independentemente de outras configurações.
# AuthenticatedUsers = Usuários com contas AWS que recebem permissões concedidas, permitindo ações limitadas no bucket.
# LogDelivery = Permissões para serviços da AWS depositarem logs diretamente no bucket, como CloudTrail ou S3 Server Access Logs.
# AllUsers = Acesso público que permite qualquer pessoa na internet interagir com o bucket (Everyone).

# Permissões originais
# canonicalUserPermissions=("READ" "WRITE" "READ_ACP" "WRITE_ACP" "FULL_CONTROL")
# authenticatedUsersPermissions=("READ" "WRITE" "READ_ACP" "WRITE_ACP" "FULL_CONTROL")
# logDeliveryPermissions=("READ" "WRITE" "READ_ACP" "WRITE_ACP" "FULL_CONTROL")
# allUsersPermissions=("READ" "WRITE" "READ_ACP" "WRITE_ACP" "FULL_CONTROL")

# Primeiro conjunto de permissões
canonicalUserPermissions=("FULL_CONTROL")
authenticatedUsersPermissions=()
logDeliveryPermissions=()
allUsersPermissions=("READ")

# Segundo conjunto de permissões
# canonicalUserPermissions=("READ" "WRITE")
# authenticatedUsersPermissions=("WRITE")
# logDeliveryPermissions=("WRITE")
# allUsersPermissions=("FULL_CONTROL")

# Terceiro conjunto de permissões
# canonicalUserPermissions=("READ_ACP" "WRITE_ACP")
# authenticatedUsersPermissions=("READ_ACP" "WRITE_ACP")
# logDeliveryPermissions=("READ_ACP" "WRITE_ACP")
# allUsersPermissions=("READ_ACP" "WRITE_ACP")

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == 'y' ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket $bucketName"
    condition=$(aws s3api list-buckets --region "$region" --query "Buckets[?Name=='$bucketName'].Name" --output text)
    if [[ -n "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo as permissões atuais dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName"
        canonicalUserCurrentlyPermissions=($(aws s3api get-bucket-acl --bucket "$bucketName" --query "Grants[?Grantee.Type=='CanonicalUser'].Permission" --output text))
        authenticatedUsersCurrentlyPermissions=($(aws s3api get-bucket-acl --bucket "$bucketName" --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AuthenticatedUsers'].Permission" --output text))
        logDeliveryCurrentlyPermissions=($(aws s3api get-bucket-acl --bucket "$bucketName" --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/s3/LogDelivery'].Permission" --output text))
        allUsersCurrentlyPermissions=($(aws s3api get-bucket-acl --bucket "$bucketName" --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text))

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando as permissões dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName se estão conforme definidas nas variáveis"
        if [[ "$(printf "%s\n" "${canonicalUserCurrentlyPermissions[@]}" | sort | tr '\n' ',')" == "$(printf "%s\n" "${canonicalUserPermissions[@]}" | sort | tr '\n' ',')" ]]; then
            canonicalUserCond=true
        else
            canonicalUserCond=false
        fi

        if [[ "$(printf "%s\n" "${authenticatedUsersCurrentlyPermissions[@]}" | sort | tr '\n' ',')" == "$(printf "%s\n" "${authenticatedUsersPermissions[@]}" | sort | tr '\n' ',')" ]]; then
            authenticatedUsersCond=true
        else
            authenticatedUsersCond=false
        fi

        if [[ "$(printf "%s\n" "${logDeliveryCurrentlyPermissions[@]}" | sort | tr '\n' ',')" == "$(printf "%s\n" "${logDeliveryPermissions[@]}" | sort | tr '\n' ',')" ]]; then
            logDeliveryCond=true
        else
            logDeliveryCond=false
        fi

        if [[ "$(printf "%s\n" "${allUsersCurrentlyPermissions[@]}" | sort | tr '\n' ',')" == "$(printf "%s\n" "${allUsersPermissions[@]}" | sort | tr '\n' ',')" ]]; then
            allUsersCond=true
        else
            allUsersCond=false
        fi

        if $canonicalUserCond && $authenticatedUsersCond && $logDeliveryCond && $allUsersCond; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já foi configurado as permissões dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName"
            aws s3api get-bucket-acl --bucket "$bucketName" --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as permissões dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName"
            aws s3api get-bucket-acl --bucket "$bucketName" --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket $bucketName é o BucketOwnerPreferred"
            condition=$(aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[?ObjectOwnership=='BucketOwnerPreferred'].ObjectOwnership" --output text)
            if [[ -n "$condition" ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "As permissões dos grupos de destinatários da ACL do bucket $bucketName já estão configuradas"
                aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[].ObjectOwnership" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o proprietário dos objetos no bucket $bucketName"
                aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[].ObjectOwnership" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Alterando o proprietário dos objetos no bucket $bucketName para BucketOwnerPreferred"
                aws s3api put-bucket-ownership-controls --bucket "$bucketName" --ownership-controls="Rules=[{ObjectOwnership=BucketOwnerPreferred}]"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o proprietário dos objetos no bucket $bucketName"
                aws s3api get-bucket-ownership-controls --bucket "$bucketName" --query "OwnershipControls.Rules[].ObjectOwnership" --output text
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se as configurações de bloqueio de acesso público do bucket $bucketName estão bloqueando ou impedindo a configuração da ACL"
            condition=$(aws s3api get-public-access-block --bucket "$bucketName" --query "PublicAccessBlockConfiguration.BlockPublicAcls && PublicAccessBlockConfiguration.IgnorePublicAcls && PublicAccessBlockConfiguration.RestrictPublicBuckets")
            if [[ "$condition" == "true" ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Alterando as configurações de bloqueio de acesso público do bucket $bucketName para permitir a configuração da ACL"
                aws s3api put-public-access-block --bucket "$bucketName" --public-access-block-configuration "BlockPublicAcls='false',IgnorePublicAcls='false',RestrictPublicBuckets='false'"
            else
                echo "As configurações de bloqueio de acesso público do bucket $bucketName não estão bloqueando ou impedindo a configuração da ACL"
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do grupo de destinatário CanonicalUser"
            idCanonicalUser=$(aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Owner.ID" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Montando os parâmetros do comando para configurar as permissões"
            fullControlGrantees=()
            if [[ "$canonicalUserPermissions" =~ "FULL_CONTROL" ]]; then fullControlGrantees+=("id=$idCanonicalUser"); fi
            if [[ "$authenticatedUsersPermissions" =~ "FULL_CONTROL" ]]; then fullControlGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"); fi
            if [[ "$logDeliveryPermissions" =~ "FULL_CONTROL" ]]; then fullControlGrantees+=("uri=http://acs.amazonaws.com/groups/s3/LogDelivery"); fi
            if [[ "$allUsersPermissions" =~ "FULL_CONTROL" ]]; then fullControlGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers"); fi
            if [ ${#fullControlGrantees[@]} -gt 0 ]; then fullControlParam="--grant-full-control \"$(IFS=,; echo "${fullControlGrantees[*]}")\""; else fullControlParam=""; fi

            readGrantees=()
            if [[ "$canonicalUserPermissions" =~ "READ" ]]; then readGrantees+=("id=$idCanonicalUser"); fi
            if [[ "$authenticatedUsersPermissions" =~ "READ" ]]; then readGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"); fi
            if [[ "$logDeliveryPermissions" =~ "READ" ]]; then readGrantees+=("uri=http://acs.amazonaws.com/groups/s3/LogDelivery"); fi
            if [[ "$allUsersPermissions" =~ "READ" ]]; then readGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers"); fi
            if [ ${#readGrantees[@]} -gt 0 ]; then readParam="--grant-read \"$(IFS=,; echo "${readGrantees[*]}")\""; else readParam=""; fi

            writeGrantees=()
            if [[ "$canonicalUserPermissions" =~ "WRITE" ]]; then writeGrantees+=("id=$idCanonicalUser"); fi
            if [[ "$authenticatedUsersPermissions" =~ "WRITE" ]]; then writeGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"); fi
            if [[ "$logDeliveryPermissions" =~ "WRITE" ]]; then writeGrantees+=("uri=http://acs.amazonaws.com/groups/s3/LogDelivery"); fi
            if [[ "$allUsersPermissions" =~ "WRITE" ]]; then writeGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers"); fi
            if [ ${#writeGrantees[@]} -gt 0 ]; then writeParam="--grant-write \"$(IFS=,; echo "${writeGrantees[*]}")\""; else writeParam=""; fi

            readAcpGrantees=()
            if [[ "$canonicalUserPermissions" =~ "READ_ACP" ]]; then readAcpGrantees+=("id=$idCanonicalUser"); fi
            if [[ "$authenticatedUsersPermissions" =~ "READ_ACP" ]]; then readAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"); fi
            if [[ "$logDeliveryPermissions" =~ "READ_ACP" ]]; then readAcpGrantees+=("uri=http://acs.amazonaws.com/groups/s3/LogDelivery"); fi
            if [[ "$allUsersPermissions" =~ "READ_ACP" ]]; then readAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers"); fi
            if [ ${#readAcpGrantees[@]} -gt 0 ]; then readAcpParam="--grant-read-acp \"$(IFS=,; echo "${readAcpGrantees[*]}")\""; else readAcpParam=""; fi

            writeAcpGrantees=()
            if [[ "$canonicalUserPermissions" =~ "WRITE_ACP" ]]; then writeAcpGrantees+=("id=$idCanonicalUser"); fi
            if [[ "$authenticatedUsersPermissions" =~ "WRITE_ACP" ]]; then writeAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"); fi
            if [[ "$logDeliveryPermissions" =~ "WRITE_ACP" ]]; then writeAcpGrantees+=("uri=http://acs.amazonaws.com/groups/s3/LogDelivery"); fi
            if [[ "$allUsersPermissions" =~ "WRITE_ACP" ]]; then writeAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers"); fi
            if [ ${#writeAcpGrantees[@]} -gt 0 ]; then writeAcpParam="--grant-write-acp \"$(IFS=,; echo "${writeAcpGrantees[*]}")\""; else writeAcpParam=""; fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Configurando as permissões dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName conforme definidas nas variáveis"
            grantCommand="aws s3api put-bucket-acl --bucket $bucketName "
            grantCommand+="$fullControlParam "
            grantCommand+="$readParam "
            grantCommand+="$writeParam "
            grantCommand+="$readAcpParam "
            grantCommand+="$writeAcpParam "
            eval $grantCommand

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Permissões atualizadas com sucesso no bucket $bucketName"
            aws s3api get-bucket-acl --bucket "$bucketName" --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
        fi
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "O bucket $bucketName não existe"
    fi
else
    echo "Operação cancelada."
fi