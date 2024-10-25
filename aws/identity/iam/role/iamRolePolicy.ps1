#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM ROLE ADD POLICY"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamRoleName = "iamRoleTest"
$policyName = "AmazonS3ReadOnlyAccess"
$policyArn = "arn:aws:iam::aws:policy/${policyName}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a role $iamRoleName e a policy $policyName"
    $condition = (aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text).Count -gt 0 -and (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a policy $policyName anexada a role $iamRoleName"
        if ((aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe a policy $policyName anexada a role $iamRoleName"
            aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as polices anexadas a role $iamRoleName"
            aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[].PolicyName" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN da policy $policyName"
            $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Vinculando a polciy $policyName a role $iamRoleName"
            aws iam attach-role-policy --role-name $iamRoleName --policy-arn $policyArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a policy $policyName anexada a role $iamRoleName"
            aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        }
    } else {Write-Output "Não existe a role $iamRoleName ou a policy $policyName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM ROLE REMOVE POLICY"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamRoleName = "iamRoleTest"
$policyName = "AmazonS3ReadOnlyAccess"
$policyArn = "arn:aws:iam::aws:policy/${policyName}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a role $iamRoleName e a policy $policyName"
    $condition = (aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text).Count -gt 0 -and (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a policy $policyName anexada a role $iamRoleName"
        if ((aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as polices anexadas a role $iamRoleName"
            aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[].PolicyName" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN da policy $policyName"
            $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a policy $policyName da role $iamRoleName"
            aws iam detach-role-policy --role-name $iamRoleName --policy-arn $policyArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as polices anexadas a role $iamRoleName"
            aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[].PolicyName" --output text
        } else {Write-Output "Não existe a policy $policyName anexada a role $iamRoleName"}
    } else {Write-Output "Não existe a role $iamRoleName ou a policy $policyName"}
} else {Write-Host "Código não executado"}