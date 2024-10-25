#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER ADD GROUP"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamGroupName = "iamGroupTest"
$iamUserName = "iamUserTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o grupo $iamGroupName e o usuário do IAM $iamUserName"
    $condition = (aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text).Count -gt 0 -and (aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o usuário do IAM $iamUserName no grupo $iamGroupName"
        $condition = aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o usuário do IAM $iamUserName no grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os usuários do IAM do grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[].UserName" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Adicionando o usuário do IAM $iamUserName ao grupo $iamGroupName"
            aws iam add-user-to-group --user-name $iamUserName --group-name $iamGroupName

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o usuário $iamUserName no grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text
        }
    } else {Write-Output "Não existe o grupo $iamGroupName ou o usuário do IAM $iamUserName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER REMOVE GROUP"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamGroupName = "iamGroupTest"
$iamUserName = "iamUserTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o grupo $iamGroupName e o usuário do IAM $iamUserName"
    $condition = (aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text).Count -gt 0 -and (aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o usuário do IAM $iamUserName no grupo $iamGroupName"
        $condition = aws iam get-group --group-name $iamGroupName --query "Users[?UserName=='$iamUserName'].UserName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os usuários do IAM do grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[].UserName" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o usuário do IAM $iamUserName do grupo $iamGroupName"
            aws iam remove-user-from-group --user-name $iamUserName --group-name $iamGroupName

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os usuários do IAM do grupo $iamGroupName"
            aws iam get-group --group-name $iamGroupName --query "Users[].UserName" --output text
        } else {Write-Output "Não existe o usuário do IAM $iamUserName no grupo $iamGroupName"}
    } else {Write-Output "Não existe o grupo $iamGroupName ou o usuário do IAM $iamUserName"}      
} else {Write-Host "Código não executado"}