#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-VPC"
Write-Output "SECURITY GROUP RULE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $sgName = "sgTest1"
$sgName = "default"
# $vpcName = "vpcTest1"
$vpcName = "default"
$port = "22"
$protocol = "tcp"
$cidrIpv4 = "0.0.0.0/0"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se a VPC é a padrão ou não"
    if ($vpcName -eq "default") {$condition = "isDefault"; $vpcNameControl = "true"
    } else {$condition = "tag:Name"; $vpcNameControl = $vpcName}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a VPC $vpcName"
    if ((aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC $vpcName"
        $vpcId = aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o security group $sgName na VPC $vpcName"
        if ((aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id do security group $sgName da VPC $vpcName"
            $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text
           
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe uma regra de entrada liberando a porta $port do security group $sgName da VPC $vpcName"
            $existRule = aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']"
            if (($existRule).Count -gt 1) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe a regra de entrada liberando a porta $port do security group $sgName da VPC $vpcName"
                $existRule
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o Id de todas as regras de entrada do security group $sgName da VPC $vpcName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Adicionando uma regra de entrada ao security group $sgName da VPC $vpcName para liberação da porta $port"
                aws ec2 authorize-security-group-ingress --group-id $sId --protocol $protocol --port $port --cidr $cidrIpv4 --no-cli-pager
            
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o Id da regra de entrada do security group $sgName da VPC $vpcName que libera a porta $port"
                aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4'].GroupId" --output text
            }
        } else {Write-Host "Não existe o security group $sgName"}
    } else {Write-Host "Não existe a VPC $vpcName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-VPC"
Write-Output "SECURITY GROUP RULE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $sgName = "sgTest1"
$sgName = "default"
# $vpcName = "vpcTest1"
$vpcName = "default"
$protocol = "tcp"
$port = "22"
$cidrIpv4 = "0.0.0.0/0"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se a VPC é a padrão ou não"
    if ($vpcName -eq "default") {$condition = "isDefault"; $vpcNameControl = "true"
    } else {$condition = "tag:Name"; $vpcNameControl = $vpcName}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a VPC $vpcName"
    if ((aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC $vpcName"
        $vpcId = aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o security group $sgName na VPC $vpcName"
        if ((aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id do security group $sgName"
            $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text
   
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe uma regra liberando a porta $port no security group $sgName"
            $existRule = aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']"
            if (($existRule).Count -gt 1) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o Id de todas as regras de entrada do security group $sgName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text
    
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Removendo a regra de entrada do security group $sgName para liberação da porta $port"
                aws ec2 revoke-security-group-ingress --group-id $sgId --protocol $protocol --port $port --cidr $cidrIpv4
    
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o Id de todas as regras de entrada do security group $sgName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

            } else {Write-Output "Não existe a regra de entrada liberando a porta $port no security group $sgName"}
        } else {Write-Host "Não existe o security group $sgName"}
    } else {Write-Host "Não existe a VPC $vpcName"}
} else {Write-Host "Código não executado"}