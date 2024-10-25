#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"
$userPassword = "SenhaTest123"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o usuário do IAM $iamUserName"
    $condition = aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe um usuário do IAM $iamUserName"
        aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o usuário do IAM $iamUserName"
        aws iam create-user --user-name $iamUserName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um perfil de login do usuário do IAM $iamUserName"
        aws iam create-login-profile --user-name $iamUserName --password $userPassword

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o usuário do IAM $iamUserName"
        aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o usuário do IAM $iamUserName"
    $condition = aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando quais grupos o usuário do IAM $iamUserName está inserido"
        $condition = aws iam list-groups-for-user --user-name $iamUserName --query 'Groups[].GroupName' --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Separando os grupos do usuário do IAM $iamUserName em uma lista"
            $groups = $condition -split "\s+"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o usuário do IAM $iamUserName dos grupos"
            foreach ($iamGroupName in $groups) {aws iam remove-user-from-group --group-name $iamGroupName --user-name $iamUserName}
        } else {Write-Output "Não existem grupos que o usuário do IAM $iamUserName faça parte"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existem policies vinculadas ao usuário do IAM $iamUserName"
        $condition = aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Separando as policies do usuário do IAM $iamUserName em uma lista"
            $policies = $condition -split "\s+"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo as policies do usuário do IAM $iamUserName"
            foreach ($policyName in $policies) {
                $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text
                aws iam detach-user-policy --user-name $iamUserName --policy-arn $policyArn    
            }
        } else {Write-Output "Não existem policies vinculadas ao usuário do IAM $iamUserName"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o perfil de login do usuário do IAM $iamUserName"
        aws iam delete-login-profile --user-name $iamUserName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o usuário do IAM $iamUserName"
        aws iam delete-user --user-name $iamUserName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os usuários do IAM criados"
        aws iam list-users --query "Users[].UserName" --output text
    } else {Write-Output "Não existe o usuário do IAM $iamUserName"}
} else {Write-Host "Código não executado"}