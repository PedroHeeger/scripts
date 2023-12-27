#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM POLICY CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$policyName = "policyTest"
$policyArn = "arn:aws:iam::001727357081:policy/policyTest"
$idAccount = "001727357081"
$pathPolicyDocument = "G:\Meu Drive\4_PROJ\scripts\scripts_model\.default\aws\iamPolicy.json"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a policy de nome $policyName"
    if ((aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a policy de nome $policyName"
        aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')].PolicyName"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a polciy de nome $policyName"
        aws iam create-policy --policy-name $policyName --policy-document "{
            `"Version`": `"2012-10-17`",
            `"Statement`": [
              {
                `"Effect`": `"Allow`",
                `"Action`": `"s3:GetObject`",
                `"Resource`": `"arn:aws:s3:::seu-bucket/*`"
              }
            ]
          }"
    
        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando a polciy de nome $policyName a partir do arquivo JSON"
        # aws iam create-policy --policy-name $policyName --policy-document file://$pathPolicyDocument

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a policy de nome $policyName"
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
$policyArn = "arn:aws:iam::001727357081:policy/policyTest"
$idAccount = "001727357081"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a policy de nome $policyName"
    if ((aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')]" --query "Policies[].PolicyName"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN da policy de nome $policyName"
        $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a policy de nome $policyName"
        aws iam delete-policy --policy-arn $policyArn

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')]" --query "Policies[].PolicyName"
    } else {Write-Output "Não existe a policy de nome $policyName"}
} else {Write-Host "Código não executado"}