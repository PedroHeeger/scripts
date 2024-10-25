#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamGroupName = "iamGroupTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o grupo $iamGroupName"
    $condition = aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o grupo $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o grupo $iamGroupName"
        aws iam create-group --group-name $iamGroupName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o grupo $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM GROUP EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamGroupName = "iamGroupTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o grupo $iamGroupName"
    $condition = aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existem usuários do IAM no grupo $iamGroupName"
        $condition = aws iam get-group --group-name $iamGroupName --query "Users[].UserName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Separando os usuários do grupo $iamGroupName em uma lista"
            $users = $condition -split "\s+"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo os usuários do grupo $iamGroupName"
            foreach ($user in $users) {aws iam remove-user-from-group --group-name $iamGroupName --user-name $user}
        } else {Write-Output "Não existem usuários do IAM no grupo $iamGroupName"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existem policies no grupo $iamGroupName"
        $condition = aws iam list-attached-group-policies --group-name $iamGroupName --query "AttachedPolicies[].PolicyName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Separando as policies do grupo $iamGroupName em uma lista"
            $policies = $condition -split "\s+"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo as policies do grupo $iamGroupName"
            foreach ($policyName in $policies) {
                $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text
                aws iam detach-group-policy --group-name $iamGroupName --policy-arn $policyArn      
            }
        } else {Write-Output "Não existem policies no grupo $iamGroupName"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o grupo $iamGroupName"
        aws iam delete-group --group-name $iamGroupName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text
    } else {Write-Output "Não existe o grupo $iamGroupName"}
} else {Write-Host "Código não executado"}