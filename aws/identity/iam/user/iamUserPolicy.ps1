#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER ADD POLICY"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"
$policyName = "AmazonS3FullAccess"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o usuário do IAM $iamUserName e a policy $policyName"
    $condition = (aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text).Count -gt 0 -and (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a policy $policyName no usuário $iamUserName"
        $condition = aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe a policy $policyName no usuário $iamUserName"
            aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as policies do usuário $iamUserName"
            aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN da policy $policyName"
            $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Adicionando a policy $policyName ao usuário $iamUserName"
            aws iam attach-user-policy --user-name $iamUserName --policy-arn $policyArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a policy $policyName do usuário $iamUserName"
            aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        }
    } else {Write-Output "Não existe o usuário do IAM $iamUserName ou a policy $policyName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER REMOVE POLICY"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"
$policyName = "AmazonS3FullAccess"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o usuário do IAM $iamUserName e a policy $policyName"
    $condition = (aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text).Count -gt 0 -and (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a policy $policyName no usuário $iamUserName"
        $condition = aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as policies do usuário $iamUserName"
            aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN da policy $policyName"
            $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a policy $policyName do usuário $iamUserName"
            aws iam detach-user-policy --user-name $iamUserName --policy-arn $policyArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as policies do usuário $iamUserName"
            aws iam list-attached-user-policies --user-name $iamUserName --query "AttachedPolicies[].PolicyName" --output text
        } else {Write-Output "Não existe a policy $policyName no usuário $iamUserName"}
    } else {Write-Output "Não existe o usuário do IAM $iamUserName ou a policy $policyName"}
} else {Write-Host "Código não executado"}