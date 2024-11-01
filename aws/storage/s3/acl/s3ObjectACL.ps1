#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "ACL OBJECT CHANGE"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
$objectName = "objTest.jpg"
# CanonicalUser = Usuário que criou o bucket, com controle total e acesso garantido independentemente de outras configurações.
# AuthenticatedUsers = Usuários com contas AWS que recebem permissões concedidas, permitindo ações limitadas no bucket.
# AllUsers = Acesso público que permite qualquer pessoa na internet interagir com o bucket (Everyone).

# Permissões originais
# $canonicalUserPermissions = @("READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL")
# $authenticatedUsersPermissions = @("READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL")
# $allUsersPermissions = @("READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL")

# Primeiro conjunto de permissões
$canonicalUserPermissions = @("FULL_CONTROL")
$authenticatedUsersPermissions = @()
$allUsersPermissions = @("READ")

# Segundo conjunto de permissões
# $canonicalUserPermissions = @("FULL_CONTROL")
# $authenticatedUsersPermissions = @("READ")
# $allUsersPermissions = @("READ")

# Terceiro conjunto de permissões
# $canonicalUserPermissions = @("READ_ACP", "WRITE_ACP")
# $authenticatedUsersPermissions = @("READ_ACP", "WRITE_ACP")
# $allUsersPermissions = @("READ_ACP", "WRITE_ACP")

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        try {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo as permissões atuais dos grupos de destinatários da ACL do objeto $objectName"   
            $canonicalUserCurrentlyPermissions=(aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.Type=='CanonicalUser'].Permission" --output text) -split '\s+'
            $authenticatedUsersCurrentlyPermissions=(aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AuthenticatedUsers'].Permission" --output text) -split '\s+'
            $allUsersCurrentlyPermissions=(aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers'].Permission" --output text) -split '\s+'

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando as permissões dos grupos de destinatários da ACL do objeto $objectName se estão conforme definidas nas variáveis"         
            if ((($canonicalUserCurrentlyPermissions | Sort-Object) -join ",") -eq (($canonicalUserPermissions | Sort-Object) -join ",")) {$canonicalUserCond=$true} else {$canonicalUserCond=$false}
            if ((($authenticatedUsersCurrentlyPermissions | Sort-Object) -join ",") -eq (($authenticatedUsersPermissions | Sort-Object) -join ",")) {$authenticatedUsersCond=$true} else {$authenticatedUsersCond=$false}
            if ((($allUsersCurrentlyPermissions | Sort-Object) -join ",") -eq (($allUsersPermissions | Sort-Object) -join ",")) {$allUsersCond=$true} else {$allUsersCond=$false}

            if ($canonicalUserCond -and $authenticatedUsersCond -and $allUsersCond) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "As permissões dos grupos de destinatários da ACL objeto $objectName já estão configuradas"
                aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todas as permissões dos grupos de destinários da ACL do objeto $objectName"
                aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo o Id do grupo de destinário CanonicalUser"
                $idCanonicalUser = aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Owner.ID" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Montando os parâmetros do comando para configurar as permissões"
                $fullControlGrantees = @()
                if ($canonicalUserPermissions -contains "FULL_CONTROL") {$fullControlGrantees += "id=$idCanonicalUser"}
                if ($authenticatedUsersPermissions -contains "FULL_CONTROL") {$fullControlGrantees += "uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"}
                if ($allUsersPermissions -contains "FULL_CONTROL") {$fullControlGrantees += "uri=http://acs.amazonaws.com/groups/global/AllUsers"}
                if ($fullControlGrantees.Count -gt 0) {$fullControlParam = "--grant-full-control `"" + ($fullControlGrantees -join ",") + "`" "} else {$fullControlParam = ""}

                $readGrantees = @()
                if ($canonicalUserPermissions -contains "READ") {$readGrantees += "id=$idCanonicalUser"}
                if ($authenticatedUsersPermissions -contains "READ") {$readGrantees += "uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"}
                if ($allUsersPermissions -contains "READ") {$readGrantees += "uri=http://acs.amazonaws.com/groups/global/AllUsers"}
                if ($readGrantees.Count -gt 0) {$readParam = "--grant-read `"" + ($readGrantees -join ",") + "`" "} else {$readParam = ""}
                
                $readAcpGrantees = @()
                if ($canonicalUserPermissions -contains "READ_ACP") {$readAcpGrantees += "id=$idCanonicalUser"}
                if ($authenticatedUsersPermissions -contains "READ_ACP") {$readAcpGrantees += "uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"}
                if ($allUsersPermissions -contains "READ_ACP") {$readAcpGrantees += "uri=http://acs.amazonaws.com/groups/global/AllUsers"}
                if ($readAcpGrantees.Count -gt 0) {$readAcpParam = "--grant-read-acp `"" + ($readAcpGrantees -join ",") + "`" "} else {$readAcpParam = ""}

                $writeAcpGrantees = @()
                if ($canonicalUserPermissions -contains "WRITE_ACP") {$writeAcpGrantees += "id=$idCanonicalUser"}
                if ($authenticatedUsersPermissions -contains "WRITE_ACP") {$writeAcpGrantees += "uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"}
                if ($allUsersPermissions -contains "WRITE_ACP") {$writeAcpGrantees += "uri=http://acs.amazonaws.com/groups/global/AllUsers"}
                if ($writeAcpGrantees.Count -gt 0) {$writeAcpParam = "--grant-write-acp `"" + ($writeAcpGrantees -join ",") + "`" "} else {$writeAcpParam = ""}

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Configurando as permissões dos grupos de destinatários da ACL do objeto $objectName conforme definidas nas variáveis"
                $grantCommand = "aws s3api put-object-acl --bucket $bucketName --key $objectName "
                $grantCommand += $fullControlParam
                $grantCommand += $readParam
                $grantCommand += $readAcpParam
                $grantCommand += $writeAcpParam
                Invoke-Expression $grantCommand

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todas as permissões dos grupos de destinários da ACL do objeto $objectName"
                aws s3api get-object-acl --bucket $bucketName --key $objectName --query "Grants[].{Grantee: Grantee.Type, URI: Grantee.URI, Permissions: Permission}" --output text
            } 
        } Catch {Write-Output "Necessário verificar as seguintes configurações do bucket ${bucketName}: bloqueio de acesso público do bucket, proprietário dos objetos (Object Ownership) e as permissões dos grupos de destinatários da ACL do bucket. Alguma dessas configurações podem estar impedindo a configuração da ACL nos objetos."} 
    } else {Write-Output "Não existe o bucket $bucketName"}
} else {Write-Host "Código não executado"}