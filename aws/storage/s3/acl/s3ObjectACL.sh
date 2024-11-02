#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON S3"
echo "ACL OBJECT CHANGE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
bucketName="bucket-test1-ph"
region="us-east-1"
objectName="objTest.jpg"
# CanonicalUser = Usuário que criou o bucket, com controle total e acesso garantido independentemente de outras configurações.
# AuthenticatedUsers = Usuários com contas AWS que recebem permissões concedidas, permitindo ações limitadas no bucket.
# AllUsers = Acesso público que permite qualquer pessoa na internet interagir com o bucket (Everyone).

# Permissões totais
# canonicalUserPermissions=("READ" "READ_ACP" "WRITE_ACP" "FULL_CONTROL")
# authenticatedUsersPermissions=("READ" "READ_ACP" "WRITE_ACP" "FULL_CONTROL")
# allUsersPermissions=("READ" "READ_ACP" "WRITE_ACP" "FULL_CONTROL")

# Primeiro conjunto de permissões
canonicalUserPermissions=("FULL_CONTROL")
authenticatedUsersPermissions=()
allUsersPermissions=("READ")

# Segundo conjunto de permissões
# canonicalUserPermissions=("FULL_CONTROL")
# authenticatedUsersPermissions=("READ")
# allUsersPermissions=("READ")

# Terceiro conjunto de permissões
# canonicalUserPermissions=("READ_ACP" "WRITE_ACP")
# authenticatedUsersPermissions=("READ_ACP" "WRITE_ACP")
# allUsersPermissions=("READ_ACP" "WRITE_ACP")

echo "-----//-----//-----//-----//-----//-----//-----"
read -rp "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == 'y' ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o bucket $bucketName"
    condition=$(aws s3api list-buckets --region "$region" --query "Buckets[?Name=='$bucketName'].Name" --output text)
    if [[ -n $condition ]]; then
        {   
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo as permissões atuais dos grupos de destinatários da ACL do objeto $objectName"
            canonicalUserCurrentlyPermissions=($(aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Grants[?Grantee.Type=='CanonicalUser'].Permission" --output text))
            authenticatedUsersCurrentlyPermissions=($(aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AuthenticatedUsers'].Permission" --output text))
            allUsersCurrentlyPermissions=($(aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text))

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando as permissões dos grupos de destinatários da ACL do objeto $objectName se estão conforme definidas nas variáveis"
            canonicalUserCond=$( [[ "$(printf "%s\n" "${canonicalUserCurrentlyPermissions[@]}" | sort)" == "$(printf "%s\n" "${canonicalUserPermissions[@]}" | sort)" ]] && echo true || echo false )
            authenticatedUsersCond=$( [[ "$(printf "%s\n" "${authenticatedUsersCurrentlyPermissions[@]}" | sort)" == "$(printf "%s\n" "${authenticatedUsersPermissions[@]}" | sort)" ]] && echo true || echo false )
            allUsersCond=$( [[ "$(printf "%s\n" "${allUsersCurrentlyPermissions[@]}" | sort)" == "$(printf "%s\n" "${allUsersPermissions[@]}" | sort)" ]] && echo true || echo false )

            if [[ $canonicalUserCond == true && $authenticatedUsersCond == true && $allUsersCond == true ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "As permissões dos grupos de destinatários da ACL objeto $objectName já estão configuradas"
                aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todas as permissões dos grupos de destinários da ACL do objeto $objectName"
                aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o Id do grupo de destinatário CanonicalUser"
                idCanonicalUser=$(aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Owner.ID" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Montando os parâmetros do comando para configurar as permissões"
                fullControlGrantees=()
                [[ " ${canonicalUserPermissions[*]} " == *" FULL_CONTROL "* ]] && fullControlGrantees+=("id=$idCanonicalUser")
                [[ " ${authenticatedUsersPermissions[*]} " == *" FULL_CONTROL "* ]] && fullControlGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
                [[ " ${allUsersPermissions[*]} " == *" FULL_CONTROL "* ]] && fullControlGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers")
                fullControlParam="${fullControlGrantees[@]:+--grant-full-control \"$(IFS=,; echo "${fullControlGrantees[*]}")\"}"

                readGrantees=()
                [[ " ${canonicalUserPermissions[*]} " == *" READ "* ]] && readGrantees+=("id=$idCanonicalUser")
                [[ " ${authenticatedUsersPermissions[*]} " == *" READ "* ]] && readGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
                [[ " ${allUsersPermissions[*]} " == *" READ "* ]] && readGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers")
                readParam="${readGrantees[@]:+--grant-read \"$(IFS=,; echo "${readGrantees[*]}")\"}"

                readAcpGrantees=()
                [[ " ${canonicalUserPermissions[*]} " == *" READ_ACP "* ]] && readAcpGrantees+=("id=$idCanonicalUser")
                [[ " ${authenticatedUsersPermissions[*]} " == *" READ_ACP "* ]] && readAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
                [[ " ${allUsersPermissions[*]} " == *" READ_ACP "* ]] && readAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers")
                readAcpParam="${readAcpGrantees[@]:+--grant-read-acp \"$(IFS=,; echo "${readAcpGrantees[*]}")\"}"

                writeAcpGrantees=()
                [[ " ${canonicalUserPermissions[*]} " == *" WRITE_ACP "* ]] && writeAcpGrantees+=("id=$idCanonicalUser")
                [[ " ${authenticatedUsersPermissions[*]} " == *" WRITE_ACP "* ]] && writeAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
                [[ " ${allUsersPermissions[*]} " == *" WRITE_ACP "* ]] && writeAcpGrantees+=("uri=http://acs.amazonaws.com/groups/global/AllUsers")
                writeAcpParam="${writeAcpGrantees[@]:+--grant-write-acp \"$(IFS=,; echo "${writeAcpGrantees[*]}")\"}"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Configurando as permissões dos grupos de destinatários da ACL do objeto $objectName conforme definidas nas variáveis"
                grantCommand="aws s3api put-object-acl --bucket \"$bucketName\" --key \"$objectName\" $fullControlParam $readParam $readAcpParam $writeAcpParam"
                eval "$grantCommand"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todas as permissões dos grupos de destinários da ACL do objeto $objectName"
                aws s3api get-object-acl --bucket "$bucketName" --key "$objectName" --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
            fi
        } || echo "Necessário verificar as seguintes configurações do bucket ${bucketName}: bloqueio de acesso público do bucket, proprietário dos objetos (Object Ownership) e as permissões dos grupos de destinatários da ACL do bucket. Alguma dessas configurações podem estar impedindo a configuração da ACL nos objetos."
    else
        echo "Não existe o bucket $bucketName"
    fi
else
    echo "Código não executado"
fi