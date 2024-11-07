#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-VPC"
Write-Output "SECURITY GROUP RULE SG CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$sgName = "default"
# $vpcName = "default"
# $sgName = "sgTest1"
$vpcName = "vpcTest1"
$sgRuleDescription = "sgRuleDescriptionTest1"
$fromPort = "22"
$toPort = "22"
$protocol = "tcp"
$referSgName = "sgReferTest1"

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
    if (($condition.Count -gt 0)) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC $vpcName"
        $vpcId = aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o security group de referência $referSgName na VPC $vpcName"
        $condition = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$referSgName" --query "SecurityGroups[].GroupName" --output text
        if (($condition).Count -gt 0) {    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id do security group de referência $referSgName"
            $referSgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$referSgName' && VpcId=='$vpcId'].GroupId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o security group $sgName na VPC $vpcName"
            $condition = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo o Id do security group $sgName da VPC $vpcName"
                $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName' && VpcId=='$vpcId'].GroupId" --output text
           
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Verificando se existe uma regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
                $condition = aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Já existe a regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
                    aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text
                } else {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando o Id de todas as regras de entrada do security group $sgName da VPC $vpcName"
                    aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Criando uma regra de entrada ao security group $sgName da VPC $vpcName para liberação da porta $fromPort"
                    aws ec2 authorize-security-group-ingress --group-id $sgId --ip-permissions "IpProtocol=$protocol,FromPort=$fromPort,ToPort=$toPort,UserIdGroupPairs=[{GroupId=$referSgId,Description='$sgRuleDescription'}]" --no-cli-pager
                
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando o Id da regra de entrada do security group $sgName da VPC $vpcName que libera a porta $fromPort"
                    aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text
                }
            } else {Write-Host "Não existe o security group $sgName"}
        } else {Write-Host "Não existe o security group de referência $referSgName"}
    } else {Write-Host "Não existe a VPC $vpcName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-VPC"
Write-Output "SECURITY GROUP RULE SG EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$sgName = "default"
# $vpcName = "default"
# $sgName = "sgTest1"
$vpcName = "vpcTest1"
$protocol = "tcp"
$port = "22"
$referSgName = "sgReferTest1"

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
        Write-Output "Verificando se existe o security group de referência $referSgName na VPC $vpcName"
        $condition = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$referSgName" --query "SecurityGroups[].GroupName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id do security group de referência $referSgName"
            $referSgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$referSgName' && VpcId=='$vpcId'].GroupId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o security group $sgName na VPC $vpcName"
            $condition = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo o Id do security group $sgName"
                $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName' && VpcId=='$vpcId'].GroupId" --output text
                
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Verificando se existe uma regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
                $condition = aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando o Id de todas as regras de entrada do security group $sgName"
                    aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text
        
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Removendo a regra de entrada do security group $sgName para liberação da porta $port"
                    aws ec2 revoke-security-group-ingress --group-id $sgId --ip-permissions "IpProtocol=$protocol,FromPort=$port,ToPort=$port,UserIdGroupPairs=[{GroupId=$referSgId}]" --no-cli-pager
        
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando o Id de todas as regras de entrada do security group $sgName"
                    aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text
                } else {Write-Output "Não existe a regra de entrada liberando a porta $port no protocolo $protocol do security group $sgName da VPC $vpcName"}
            } else {Write-Host "Não existe o security group $sgName"}
        } else {Write-Host "Não existe o security group de referência $referSgName"}
    } else {Write-Host "Não existe a VPC $vpcName"}
} else {Write-Host "Código não executado"}