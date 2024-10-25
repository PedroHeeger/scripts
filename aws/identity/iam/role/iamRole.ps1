#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM ROLE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamRoleName = "iamRoleTest"
# $pathTrustPolicyDocument = "G:\Meu Drive\4_PROJ\scripts\aws\.default\policy\iam\iamTrustPolicy.json"

# SERVICE:
$principal = "Service"
$principalName = "ec2.amazonaws.com"

# USER:
# $principal = "AWS"
# $accountId = "001727357081"
# $iamUserName = "iamUserTest"
# $principalName = "arn:aws:iam::${accountId}:user/${iamUserName}"

# ROLE:
# $principal = "AWS"
# $accountId = "001727357081"
# $iamRoleName2 = "iamRoleTest2"
# $principalName = "arn:aws:iam::${accountId}:role/${iamRoleName2}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a role $iamRoleName"
    $condition = aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe uma role $iamRoleName"
        aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a role $iamRoleName"
        aws iam create-role --role-name $iamRoleName --assume-role-policy-document "{
            `"Version`": `"2012-10-17`",
            `"Statement`": [
              {
                `"Effect`": `"Allow`",
                `"Principal`": {`"$principal`": `"$principalName`"},
                `"Action`": `"sts:AssumeRole`"
              }
            ]
          }" --no-cli-pager
    
        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando a role $iamRoleName com um arquivo JSON"
        # aws iam create-role --role-name $iamRoleName --assume-role-policy-document file://$pathTrustPolicyDocument
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a role $iamRoleName"
        aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM ROLE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamRoleName = "iamRoleTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a role $iamRoleName"
    $condition = aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existem policies na role $iamRoleName"
        $condition = aws iam list-attached-role-policies --role-name $iamRoleName --query 'AttachedPolicies[].PolicyName' --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Separando as policies da role $iamRoleName em uma lista"
            $policies = $condition -split "\s+"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo as policies da role $iamRoleName"
            foreach ($policyName in $policies) {
                $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text
                aws iam detach-role-policy --role-name $iamRoleName --policy-arn $policyArn   
            }
        } else {Write-Output "Não existem policies na role $iamRoleName"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a role $iamRoleName"
        aws iam delete-role --role-name $iamRoleName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as roles criadas"
        aws iam list-roles --query 'Roles[].RoleName' --output text
    } else {Write-Output "Não existe a role $iamRoleName"}
} else {Write-Host "Código não executado"}