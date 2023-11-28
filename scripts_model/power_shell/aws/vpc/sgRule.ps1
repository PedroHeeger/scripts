#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS VPC"
Write-Output "SECURITY GROUP RULE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$groupName = "default"
$protocolo = "tcp"
$port = "22"
$cidrIpv4 = "0.0.0.0/0"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a VPC padrão"
    if ((aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC padrão"
        $vpcDefaultId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o Security Group padrão da VPC padrão"
        if ((aws ec2 describe-security-groups --filters "Name=vpc-id,Values='$vpcDefaultId'" --query "SecurityGroups[?GroupName=='$groupName'].GroupId").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id do Security Group padrão"
            $sgDefaultId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe uma regra liberando a porta $port do Security Group padrão"
            $existRule = aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgDefaultId' && !IsEgress && IpProtocol=='$protocolo' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']"
            if (($existRule).Count -gt 1) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe a regra de entrada liberando a porta $port do Security Group padrão"
                $existRule
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text
            
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Adicionando uma regra de entrada ao Security Group padrão para liberação da porta $port"
                aws ec2 authorize-security-group-ingress --group-id $sgDefaultId --protocol $protocolo --port $port --cidr $cidrIpv4 --no-cli-pager
            
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text
            }
        }
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS VPC"
Write-Output "SECURITY GROUP RULE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$groupName = "default"
$protocolo = "tcp"
$port = "22"
$cidrIpv4 = "0.0.0.0/0"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a VPC padrão"
    if ((aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC padrão"
        $vpcDefaultId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o Security Group padrão da VPC padrão"
        if ((aws ec2 describe-security-groups --filters "Name=vpc-id,Values='$vpcDefaultId'" --query "SecurityGroups[?GroupName=='$groupName'].GroupId").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id do Security Group padrão"
            $sgDefaultId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe uma regra liberando a porta $port no Security Group padrão"
            $existRule = aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgDefaultId' && !IsEgress && IpProtocol=='$protocolo' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']"
            if (($existRule).Count -gt 1) {
                Write-Output "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text
    
                Write-Output "Removendo a regra de entrada do Security Group padrão para liberação da porta $port"
                aws ec2 revoke-security-group-ingress --group-id $sgDefaultId --protocol $protocolo --port $port --cidr $cidrIpv4
    
                Write-Output "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text
            } else {Write-Output "Não existe a regra de entrada liberando a porta $port no Security Group padrão"}
        }
    }
} else {Write-Host "Código não executado"}