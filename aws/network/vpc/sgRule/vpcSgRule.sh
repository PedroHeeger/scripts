#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "SECURITY GROUP RULE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
sgName="default"
vpcName="default"
# sgName="sgTest1"
# vpcName="vpcTest1"
sgRuleDescription="sgRuleDescriptionTest1"
fromPort="22"
toPort="22"
protocol="tcp"
cidrIpv4="0.0.0.0/0"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se a VPC é a padrão ou não"
    if [ "$vpcName" == "default" ]; then
        key="isDefault"
        vpcNameControl="true"
    else
        key="tag:Name"
        vpcNameControl="$vpcName"
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a VPC $vpcName"
    condition=$(aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC $vpcName"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o security group $sgName na VPC $vpcName"
        condition=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do security group $sgName da VPC $vpcName"
            sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName' && VpcId=='$vpcId'].GroupId" --output text)
           
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe uma regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
            condition=$(aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && CidrIpv4=='$cidrIpv4'].SecurityGroupRuleId" --output text | wc -l)
            if [[ "$condition" -gt 0 ]]; then 
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe a regra de entrada liberando a porta $fromPort do security group $sgName da VPC $vpcName"
                aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && CidrIpv4=='$cidrIpv4'].SecurityGroupRuleId" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada do security group $sgName da VPC $vpcName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

                # echo "-----//-----//-----//-----//-----//-----//-----"
                # echo "Adicionando uma regra de entrada ao security group $sgName da VPC $vpcName para liberação da porta $fromPort"
                # aws ec2 authorize-security-group-ingress --group-id $sgId --protocol $protocol --port $fromPort --cidr $cidrIpv4 --description $sgRuleDescription --no-cli-pager
            
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Adicionando uma regra de entrada ao security group $sgName da VPC $vpcName para liberação da porta $fromPort"
                aws ec2 authorize-security-group-ingress --group-id $sgId --ip-permissions "IpProtocol=$protocol,FromPort=$fromPort,ToPort=$toPort,IpRanges=[{CidrIp=$cidrIpv4,Description='$sgRuleDescription'}]" --no-cli-pager

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id da regra de entrada do security group $sgName da VPC $vpcName que libera a porta $fromPort"
                aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && CidrIpv4=='$cidrIpv4'].SecurityGroupRuleId" --output text
            fi
        else
            echo "Não existe o security group $sgName na VPC $vpcName"
        fi
    else
        echo "Não existe a VPC $vpcName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "SECURITY GROUP RULE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
sgName="default"
vpcName="default"
# sgName="sgTest1"
# vpcName="vpcTest1"
protocol="tcp"
fromPort="22"
toPort="22"
cidrIpv4="0.0.0.0/0"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se a VPC é a padrão ou não"
    if [ "$vpcName" == "default" ]; then
        key="isDefault"
        vpcNameControl="true"
    else
        key="tag:Name"
        vpcNameControl="$vpcName"
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a VPC $vpcName"
    condition=$(aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC $vpcName"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=$key,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o security group $sgName na VPC $vpcName"
        condition=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do security group $sgName"
            sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName' && VpcId=='$vpcId'].GroupId" --output text)
   
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe uma regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
            condition=$(aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && CidrIpv4=='$cidrIpv4'].SecurityGroupRuleId" --output text | wc -l)
            if [[ "$condition" -gt 0 ]]; then 
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada do security group $sgName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text
    
                # echo "-----//-----//-----//-----//-----//-----//-----"
                # echo "Removendo a regra de entrada do security group $sgName para liberação da porta $fromPort"
                # aws ec2 revoke-security-group-ingress --group-id $sgId --protocol $protocol --port $fromPort --cidr $cidrIpv4

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo a regra de entrada do security group $sgName para liberação da porta $fromPort"
                aws ec2 revoke-security-group-ingress --group-id $sgId --ip-permissions "IpProtocol=$protocol,FromPort=$fromPort,ToPort=$toPort,IpRanges=[{CidrIp=$cidrIpv4}]" --no-cli-pager
    
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada do security group $sgName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

            else
                echo "Não existe a regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
            fi
        else
            echo "Não existe o security group $sgName na VPC $vpcName"
        fi
    else
        echo "Não existe a VPC $vpcName"
    fi
else
    echo "Código não executado"
fi