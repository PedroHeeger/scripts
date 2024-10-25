#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM POLICY CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$policyName = "policyTest"
$idAccount = "001727357081"
$policyArn = "arn:aws:iam::${idAccount}:policy/${policyName}"
# $pathPolicyDocument = "G:\Meu Drive\4_PROJ\scripts\aws\.default\policy\iam\iamPolicy.json"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a policy $policyName"
    $condition = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a policy $policyName"
        aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')].PolicyName"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a polciy $policyName"
        aws iam create-policy --policy-name $policyName --policy-document "{
            `"Version`": `"2012-10-17`",
            `"Statement`": [
              {
                `"Effect`": `"Allow`",
                `"Action`": `"s3:GetObject`",
                `"Resource`": `"arn:aws:s3:::seu-bucket/*`"
              }
            ]
          }" --no-cli-pager
    
        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando a polciy $policyName a partir do arquivo JSON"
        # aws iam create-policy --policy-name $policyName --policy-document file://$pathPolicyDocument

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a policy $policyName"
        aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM POLICY EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$policyName = "policyTest"
$idAccount = "001727357081"
$policyArn = "arn:aws:iam::${idAccount}:policy/${policyName}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a policy $policyName"
    $condition = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')].PolicyName"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN da policy $policyName"
        $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a policy $policyName"
        aws iam delete-policy --policy-arn $policyArn

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')].PolicyName"
    } else {Write-Output "Não existe a policy $policyName"}
} else {Write-Host "Código não executado"}