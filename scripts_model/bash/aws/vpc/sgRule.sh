#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS VPC"
echo "SECURITY GROUP RULE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
groupName="default"
protocolo="tcp"
port="22"
cidrIpv4="0.0.0.0/0"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a VPC padrão"
    vpcs=($(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text))

    if [ "${#vpcs[@]}" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC padrão"
        vpcDefaultId="${vpcs[0]}"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o Security Group padrão da VPC padrão"
        sgs=($(aws ec2 describe-security-groups --filters "Name=vpc-id,Values='$vpcDefaultId'" --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text))

        if [ "${#sgs[@]}" -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do Security Group padrão"
            sgDefaultId="${sgs[0]}"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe uma regra liberando a porta $port do Security Group padrão"
            existRule=$(aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgDefaultId' && !IsEgress && IpProtocol=='$protocolo' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']" --output text)
            numExistRules=$(echo "$existRule" | wc -l)

            if [ "$numExistRules" -gt 1 ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe a regra de entrada liberando a porta $port do Security Group padrão"
                echo "$existRule"
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Adicionando uma regra de entrada ao Security Group padrão para liberação da porta $port"
                aws ec2 authorize-security-group-ingress --group-id "$sgDefaultId" --protocol "$protocolo" --port "$port" --cidr "$cidrIpv4" --no-cli-pager

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text
            fi
        fi
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS VPC"
echo "SECURITY GROUP RULE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
groupName="default"
protocolo="tcp"
port="22"
cidrIpv4="0.0.0.0/0"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a VPC padrão"
    vpcs=($(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text))

    if [ "${#vpcs[@]}" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC padrão"
        vpcDefaultId="${vpcs[0]}"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o Security Group padrão da VPC padrão"
        securityGroups=($(aws ec2 describe-security-groups --filters "Name=vpc-id,Values='$vpcDefaultId'" --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text))

        if [ "${#securityGroups[@]}" -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do Security Group padrão"
            sgDefaultId="${securityGroups[0]}"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe uma regra liberando a porta $port no Security Group padrão"
            existRule=$(aws ec2 describe-security-group-rules --query"SecurityGroupRules[?GroupId=='$sgDefaultId' && !IsEgress && IpProtocol=='$protocolo' && to_string(FromPort)=='$port' && to_string(ToPort)=='$port' && CidrIpv4=='$cidrIpv4']" --output text)
            
            if [ -n "$existRule" ]; then
                echo "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text

                echo "Removendo a regra de entrada do Security Group padrão para liberação da porta $port"
                aws ec2 revoke-security-group-ingress --group-id $sgDefaultId --protocol $protocolo --port $port --cidr $cidrIpv4

                echo "Listando o Id de todas as regras de entrada e saída do Security Group padrão"
                aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgDefaultId" --query "SecurityGroupRules[].SecurityGroupRuleId" --output text
            else
                echo "Não existe a regra de entrada liberando a porta $port no Security Group padrão"
            fi
        fi
    fi
else
    echo "Código não executado"
fi