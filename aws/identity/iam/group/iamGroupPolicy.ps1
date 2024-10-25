#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM GROUP ADD POLICY"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamGroupName = "iamGroupTest"
$policyName = "AmazonS3ReadOnlyAccess"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o grupo $iamGroupName e a policy $policyName"
    $condition = (aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text).Count -gt 0 -and (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a policy $policyName no grupo $iamGroupName"
        $condition = aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe a policy $policyName no grupo $iamGroupName"
            aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as policies do grupo $iamGroupName"
            aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[].PolicyName" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN da policy $policyName"
            $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Adicionando a policy $policyName ao grupo $iamGroupName"
            aws iam attach-group-policy --group-name $iamGroupName --policy-arn $policyArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a policy $policyName do grupo $iamGroupName"
            aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        }
    } else {Write-Output "Não existe o grupo $iamGroupName ou a policy $policyName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM GROUP REMOVE POLICY"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamGroupName = "iamGroupTest"
$policyName = "AmazonS3ReadOnlyAccess"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o grupo $iamGroupName e a policy $policyName"
    $condition = (aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text).Count -gt 0 -and (aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a policy $policyName no grupo $iamGroupName"
        $condition = aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as policies do grupo $iamGroupName"
            aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[].PolicyName" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN da policy $policyName"
            $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a policy $policyName do grupo $iamGroupName"
            aws iam detach-group-policy --group-name $iamGroupName --policy-arn $policyArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as policies do grupo $iamGroupName"
            aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[].PolicyName" --output text
        } else {Write-Output "Não existe a policy $policyName no grupo $iamGroupName"}
    } else {Write-Output "Não existe o grupo $iamGroupName ou a policy $policyName"}     
} else {Write-Host "Código não executado"}