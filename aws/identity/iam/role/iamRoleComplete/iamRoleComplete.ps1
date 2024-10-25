#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM INSTANCE PROFILE + ROLE + POLICY CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamRoleName = "iamRoleTest"
$instanceProfileName = "instanceProfileTest"
$policyName = "AmazonS3ReadOnlyAccess"
# $policyName = "policyTest"
$policyArn = "arn:aws:iam::aws:policy/${policyName}"
# $pathTrustPolicyDocument = "G:\Meu Drive\4_PROJ\scripts\aws\.default\policy\iam\iamTrustPolicy.json"
# $pathPolicyDocument = "G:\Meu Drive\4_PROJ\scripts\aws\.default\policy\iam\iamPolicy.json"

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
# $iamRoleName2 = "iamGroupTest2"
# $principalName = "arn:aws:iam::${accountId}:role/${iamRoleName2}"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    function VerificarOuCriarPerfilDeInstancia {
        param ([string]$instanceProfileName, [string]$iamRoleName)
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o perfil de instância $instanceProfileName"
        $condition = aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o perfil de instância $instanceProfileName"
            aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o perfil de instância $instanceProfileName"
            aws iam create-instance-profile --instance-profile-name $instanceProfileName
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Adicionando a role $iamRoleName ao perfil de instância $instanceProfileName"
            aws iam add-role-to-instance-profile --instance-profile-name $instanceProfileName --role-name $iamRoleName
        }
    }

    function VincularPolicyARole {
        param ([string]$policyName, [string]$iamRoleName)
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN da policy $policyName"
        $policyArn = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Vinculando a policy $policyName à role $iamRoleName"
        aws iam attach-role-policy --role-name $iamRoleName --policy-arn $policyArn
    }


    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a role $iamRoleName"
    $condition = aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    if (($condition).Count -gt 0) {
        VerificarOuCriarPerfilDeInstancia -instanceProfileName $instanceProfileName -iamRoleName $iamRoleName
    } else {
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
        Write-Output "Verificando se existe a policy $policyName"
        $condition = aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe a policy $policyName anexada a role $iamRoleName"
            if ((aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName").Count -gt 1) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe a policy $policyName anexada a role $iamRoleName"
                aws iam list-attached-role-policies --role-name $iamRoleName --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text   
            } else {
                VincularPolicyARole -policyName $policyName -iamRoleName $iamRoleName
            }
        } else {
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

            VincularPolicyARole -policyName $policyName -iamRoleName $iamRoleName
        }

        VerificarOuCriarPerfilDeInstancia -instanceProfileName $instanceProfileName -iamRoleName $iamRoleName
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM INSTANCE PROFILE + ROLE + POLICY EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamRoleName = "iamRoleTest"
$instanceProfileName = "instanceProfileTest"
$policyName = "AmazonS3ReadOnlyAccess"
# $policyName = "policyTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    function RemoverPoliciesERole {
        param ([string]$iamRoleName)
    
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
    }


    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a role $iamRoleName"
    $condition = aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o perfil de instância $instanceProfileName"
        $condition = aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a role $iamRoleName do perfil de instância $instanceProfileName"
            aws iam remove-role-from-instance-profile --instance-profile-name $instanceProfileName --role-name $iamRoleName

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o perfil de instância $instanceProfileName"
            aws iam delete-instance-profile --instance-profile-name $instanceProfileName

            RemoverPoliciesERole -iamRoleName $iamRoleName
        } else {
            RemoverPoliciesERole -iamRoleName $iamRoleName
        }
    } else {Write-Output "Não existe a role $iamRoleName"}
} else {Write-Host "Código não executado"}