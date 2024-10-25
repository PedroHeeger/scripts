#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER KEY ACCESS CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"
$keyAccessFile = "keyAccessTest.json"
$keyAccessPath = "G:\Meu Drive\4_PROJ\scripts\aws\.default\secrets\accessKey"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o usuário do IAM $iamUserName"
    $condition = aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe chave de acesso para o usuário do IAM $iamUserName"
        $condition = aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe uma chave de acesso criada para o usuário do IAM $iamUserName"
            aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as chaves de acesso cridadas do usuário do IAM $iamUserName"
            aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando uma chave de acesso para o usuário do IAM $iamUserName"
            aws iam create-access-key --user-name $iamUserName > "$keyAccessPath\$keyAccessFile"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando as chaves de acesso do usuário do IAM $iamUserName"
            aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
        }
    } else {Write-Output "Não existe o usuário do IAM $iamUserName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER KEY ACCESS EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"
$keyAccessFile = "keyAccessTest.json"
$keyAccessPath = "G:\Meu Drive\4_PROJ\scripts\aws\.default\secrets\accessKey"
# $keyAccessId = "AKIAQCPZALZ6WNXS6ZEJ"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o usuário do IAM $iamUserName"
    $condition = aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe chave de acesso para o usuário do IAM $iamUserName"
        $condition = aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as chaves de acesso cridadas do usuário do IAM $iamUserName"
            aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo Id da primeira chave de acesso existente"
            $keyAccessId = aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[0].AccessKeyId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a chave de acesso do usuário do IAM $iamUserName"
            aws iam delete-access-key --user-name $iamUserName --access-key-id $keyAccessId

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o arquivo de chave de acesso $keyAccessFile"
            if (Test-Path "$keyAccessPath\$keyAccessFile" -PathType Leaf) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Host "Removendo o arquivo de chave de acesso $keyAccessFile"
                Remove-Item "$keyAccessPath\$keyAccessFile"
            } else {Write-Host "Não existe o arquivo de chave de acesso $keyAccessFile"}

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as chaves de acesso cridadas do usuário do IAM $iamUserName"
            aws iam list-access-keys --user-name $iamUserName --query "AccessKeyMetadata[].AccessKeyId" --output text
        } else {Write-Output "Não existe uma chave de acesso para o usuário do IAM $iamUserName"}
    } else {Write-Output "Não existe o usuário do IAM $iamUserName"}
} else {Write-Host "Código não executado"}