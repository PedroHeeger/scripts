#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "SECURITY GROUP RULE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# sgName="sgTest1"
sgName="default"
# vpcName="vpcTest1"
vpcName="default"
port="80"
protocol="tcp"
cidrIpv4="0.0.0.0/0"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se a VPC é a padrão ou não"
    if [ "$vpcName" == "default" ]; then
        condition="isDefault"
        vpcNameControl="true"
    else
        condition="tag:Name"
        vpcNameControl="$vpcName"
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a VPC $vpcName"
    if [ $(aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC $vpcName"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o security group $sgName na VPC $vpcName"
        if [ $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do security group $sgName da VPC $vpcName"
            sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)
           
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe uma regra liberando a porta $port no security group $sgName"
            existRule=$(aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']" --output text)
            if [ -n "$existRule" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe a regra de entrada liberando a porta $port do security group $sgName da VPC $vpcName"
                echo "$existRule"
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada do security group $sgName da VPC $vpcName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Adicionando uma regra de entrada ao security group $sgName da VPC $vpcName para liberação da porta $port"
                aws ec2 authorize-security-group-ingress --group-id $sId --protocol $protocol --port $port --cidr $cidrIpv4 --no-cli-pager
            
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id da regra de entrada do security group $sgName da VPC $vpcName que libera a porta $port"
                aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4'].GroupId" --output text
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
# sgName="sgTest1"
sgName="default"
# vpcName="vpcTest1"
vpcName="default"
protocol="tcp"
port="80"
cidrIpv4="0.0.0.0/0"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se a VPC é a padrão ou não"
    if [ "$vpcName" == "default" ]; then
        condition="isDefault"
        vpcNameControl="true"
    else
        condition="tag:Name"
        vpcNameControl="$vpcName"
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a VPC $vpcName"
    if [ $(aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC $vpcName"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o security group $sgName na VPC $vpcName"
        if [ $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do security group $sgName"
            sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)
   
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe uma regra liberando a porta $port no security group $sgName"
            existRule=$(aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']" --output text)
            if [ -n "$existRule" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada do security group $sgName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text
    
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo a regra de entrada do security group $sgName para liberação da porta $port"
                aws ec2 revoke-security-group-ingress --group-id $sgId --protocol $protocol --port $port --cidr $cidrIpv4
    
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada do security group $sgName"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

            else
                echo "Não existe a regra de entrada liberando a porta $port no security group $sgName"
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