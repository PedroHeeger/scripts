#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "ACL BUCKET CHANGE"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
# CanonicalUser = Usuário que criou o bucket, com controle total e acesso garantido independentemente de outras configurações.
# AuthenticatedUsers = Usuários com contas AWS que recebem permissões concedidas, permitindo ações limitadas no bucket.
# LogDelivery = Permissões para serviços da AWS depositarem logs diretamente no bucket, como CloudTrail ou S3 Server Access Logs.
# AllUsers = Acesso público que permite qualquer pessoa na internet interagir com o bucket (Everyone).

# $canonicalUserPermissions = @("READ", "WRITE", "FULL_CONTROL")
# $authenticatedUsersPermissions = @("READ", "WRITE", "FULL_CONTROL")
# $logDeliveryPermissions = @("READ", "WRITE", "FULL_CONTROL")
# $allUsersPermissions = @("READ", "WRITE", "FULL_CONTROL")

$canonicalUserPermissions = @("WRITE")
$authenticatedUsersPermissions = @("READ")
$logDeliveryPermissions = @("READ")
$allUsersPermissions = @("READ", "WRITE")

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo as permissões atuais dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName"   
        $canonicalUserCurrentlyPermissions=(aws s3api get-bucket-acl --bucket bucket-test1-ph --query "Grants[?Grantee.Type=='CanonicalUser'].Permission" --output text) -split '\s+'
        $authenticatedUsersCurrentlyPermissions=(aws s3api get-bucket-acl --bucket bucket-test1-ph --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AuthenticatedUsers'].Permission" --output text) -split '\s+'
        $logDeliveryCurrentlyPermissions=(aws s3api get-bucket-acl --bucket bucket-test1-ph --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/s3/LogDelivery'].Permission" --output text) -split '\s+'
        $allUsersCurrentlyPermissions=(aws s3api get-bucket-acl --bucket bucket-test1-ph --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text) -split '\s+'

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando as permissões dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName se estão conforme definido nas variáveis"         
        if ((($canonicalUserCurrentlyPermissions | Sort-Object) -join ",") -eq (($canonicalUserPermissions | Sort-Object) -join ",")) {$canonicalUserCond=$true} else {$canonicalUserCond=$false}
        if ((($authenticatedUsersCurrentlyPermissions | Sort-Object) -join ",") -eq (($authenticatedUsersPermissions | Sort-Object) -join ",")) {$authenticatedUsersCond=$true} else {$authenticatedUsersCond=$false}
        if ((($logDeliveryCurrentlyPermissions | Sort-Object) -join ",") -eq (($logDeliveryPermissions | Sort-Object) -join ",")) {$logDeliveryCond=$true} else {$logDeliveryCond=$false}
        if ((($allUsersCurrentlyPermissions | Sort-Object) -join ",") -eq (($allUsersPermissions | Sort-Object) -join ",")) {$allUsersCond=$true} else {$allUsersCond=$false}

        if ($canonicalUserCond -and $authenticatedUsersCond -and $logDeliveryCond -and $allUsersCond) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já foi configurado as permissões dos grupos de destinários da ACL sobre os objetos do bucket $bucketName"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as permissões dos grupos de destinários da ACL sobre os objetos do bucket $bucketName"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket $bucketName é o BucketOwnerPreferred"
            $condition = aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[?ObjectOwnership=='BucketOwnerPreferred'].ObjectOwnership" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já foi configurado o proprietário dos objetos no bucket $bucketName para BucketOwnerPreferred"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text   
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o proprietário dos objetos no bucket $bucketName"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Alterando o proprietário dos objetos no bucket $bucketName para BucketOwnerPreferred"
                aws s3api put-bucket-ownership-controls --bucket $bucketName --ownership-controls="Rules=[{ObjectOwnership=BucketOwnerPreferred}]"

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o proprietário dos objetos no bucket $bucketName"
                aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text 
            }

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se as configurações de bloqueio de acesso público do bucket $bucketName estão bloqueando ou impedindo a configuração da ACL"
            $condition = aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration.BlockPublicAcls && PublicAccessBlockConfiguration.IgnorePublicAcls && PublicAccessBlockConfiguration.RestrictPublicBuckets"
            if ($condition -eq "true") {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Alterando as configurações de bloqueio de acesso público do bucket $bucketName para permitir a configuração da ACL"
                aws s3api put-public-access-block --bucket $bucketName --public-access-block-configuration "BlockPublicAcls='false',IgnorePublicAcls='false',RestrictPublicBuckets='false'"
            } else {Write-Output "As configurações de bloqueio de acesso público do bucket $bucketName não estão bloqueando ou impedindo a configuração da ACL"}

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Configurando as permissões dos grupos de destinatários da ACL sobre os objetos do bucket $bucketName conforme definido nas variáveis"
            $grantCommand = "aws s3api put-bucket-acl --bucket $bucketName "
            if ($canonicalUserPermissions -contains "FULL_CONTROL") {$grantCommand += "--grant-full-control `"id=b43be637d21bb9c0448978f329c2fd466779dde5204bb35b0043edad488bc3d0`" "}
            if ($canonicalUserPermissions -contains "WRITE") {$grantCommand += "--grant-write `"id=b43be637d21bb9c0448978f329c2fd466779dde5204bb35b0043edad488bc3d0`" "}
            if ($canonicalUserPermissions -contains "READ") {$grantCommand += "--grant-read `"id=b43be637d21bb9c0448978f329c2fd466779dde5204bb35b0043edad488bc3d0`" "}

            if ($authenticatedUsersPermissions -contains "FULL_CONTROL") {$grantCommand += "--grant-full-control `"uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers`" "}
            if ($authenticatedUsersPermissions -contains "WRITE") {$grantCommand += "--grant-write `"uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers`" "}
            if ($authenticatedUsersPermissions -contains "READ") {$grantCommand += "--grant-read `"uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers`" "}

            if ($logDeliveryPermissions -contains "FULL_CONTROL") {$grantCommand += "--grant-full-control `"uri=http://acs.amazonaws.com/groups/s3/LogDelivery`" "}
            if ($logDeliveryPermissions -contains "WRITE") {$grantCommand += "--grant-write `"uri=http://acs.amazonaws.com/groups/s3/LogDelivery`" "}
            if ($logDeliveryPermissions -contains "READ") {$grantCommand += "--grant-read `"uri=http://acs.amazonaws.com/groups/s3/LogDelivery`" "}

            if ($allUsersPermissions -contains "FULL_CONTROL") {$grantCommand += "--grant-full-control `"uri=http://acs.amazonaws.com/groups/global/AllUsers`" "}
            if ($allUsersPermissions -contains "WRITE") {$grantCommand += "--grant-write `"uri=http://acs.amazonaws.com/groups/global/AllUsers`" "}
            if ($allUsersPermissions -contains "READ") {$grantCommand += "--grant-read `"uri=http://acs.amazonaws.com/groups/global/AllUsers`" "}
            # Invoke-Expression $grantCommand
            $grantCommand

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as permissões dos grupos de destinários da ACL sobre os objetos do bucket $bucketName"
            aws s3api get-bucket-acl --bucket $bucketName --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
        }
    } else {Write-Output "Não existe o bucket $bucketName"}
} else {Write-Host "Código não executado"}