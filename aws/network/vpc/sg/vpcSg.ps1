#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-VPC"
Write-Output "SECURITY GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$sgName = "sgTest1"
# $sgName = "default"
$vpcName = "vpcTest1"
# $vpcName = "default"
$sgDescription = "Security Group Test1"
$sgTagName = "sgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se a VPC é a padrão ou não"
    if ($vpcName -eq "default") {$key = "isDefault"; $vpcNameControl = "true"
    } else {$key = "tag:Name"; $vpcNameControl = $vpcName}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a VPC $vpcName"
    $condition = aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC $vpcName"
        $vpcId = aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o security group $sgName na VPC $vpcName"
        $condition = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o security group $sgName na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os security groups criados na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" --query "SecurityGroups[].GroupName" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o security group $sgName na VPC $vpcName"
            aws ec2 create-security-group --group-name $sgName --description $sgDescription --vpc-id $vpcId --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$sgTagName}]"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o security group $sgName na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
        }
    } else {Write-Host "Não existe a VPC $vpcName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-VPC"
Write-Output "SECURITY GROUP EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$sgName = "sgTest1"
# $sgName = "default"
$vpcName = "vpcTest1"
# $vpcName = "default"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se a VPC é a padrão ou não"
    if ($vpcName -eq "default") {$key = "isDefault"; $vpcNameControl = "true"
    } else {$key = "tag:Name"; $vpcNameControl = $vpcName}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a VPC $vpcName"
    $condition = aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC $vpcName"
        $vpcId = aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o security group $sgName na VPC $vpcName"
        $condition = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os security groups criados na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" --query "SecurityGroups[].GroupName" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id do security group $sgName da VPC $vpcName"
            $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o security group $sgName da VPC $vpcName"
            aws ec2 delete-security-group --group-id $sgId

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os security groups criados na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" --query "SecurityGroups[].GroupName" --output text
        } else {Write-Host "Não existe o security group $sgName na VPC $vpcName"}
    } else {Write-Host "Não existe a VPC $vpcName"}
} else {Write-Host "Código não executado"}