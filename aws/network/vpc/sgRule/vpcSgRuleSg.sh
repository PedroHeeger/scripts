#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "SECURITY GROUP RULE SG CREATION"

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
referSgName="sgReferTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (s/n) " resposta
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
        echo "Verificando se existe o security group de referência $referSgName na VPC $vpcName"
        condition=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$referSgName" --query "SecurityGroups[].GroupName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do security group de referência $referSgName"
            referSgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$referSgName'].GroupId" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o security group $sgName na VPC $vpcName"
            condition=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text | wc -l)
            if [[ "$condition" -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o Id do security group $sgName da VPC $vpcName"
                sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName' && VpcId=='$vpcId'].GroupId" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe uma regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
                condition=$(aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text | wc -l)
                if [[ "$condition" -gt 0 ]]; then 
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Já existe a regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
                    aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text
                else
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando o Id de todas as regras de entrada do security group $sgName da VPC $vpcName"
                    aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Criando uma regra de entrada ao security group $sgName da VPC $vpcName para liberação da porta $fromPort"
                    aws ec2 authorize-security-group-ingress --group-id $sgId --ip-permissions "IpProtocol=$protocol,FromPort=$fromPort,ToPort=$toPort,UserIdGroupPairs=[{GroupId=$referSgId,Description='$sgRuleDescription'}]" --no-cli-pager

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando o Id da regra de entrada do security group $sgName da VPC $vpcName que libera a porta $fromPort"
                    aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort' && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text
                fi
            else
                echo "Não existe o security group $sgName"
            fi
        else
            echo "Não existe o security group de referência $referSgName"
        fi
    else
        echo "Não existe a VPC $vpcName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "SECURITY GROUP RULE SG EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
sgName="default"
vpcName="default"
# sgName="sgTest1"
# vpcName="vpcTest1"
protocol="tcp"
port="22"
referSgName="sgReferTest1"

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
        echo "Verificando se existe o security group de referência $referSgName na VPC $vpcName"
        condition=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$referSgName" --query "SecurityGroups[].GroupName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do security group de referência $referSgName"
            referSgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$referSgName'].GroupId" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o security group $sgName na VPC $vpcName"
            condition=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text | wc -l)
            if [[ "$condition" -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o Id do security group $sgName"
                sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName' && VpcId=='$vpcId'].GroupId" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o Id do security group vinculado $referSgName"
                referSgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$referSgName'].GroupId" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe uma regra de entrada liberando a porta $fromPort no protocolo $protocol do security group $sgName da VPC $vpcName"
                condition=$(aws ec2 describe-security-group-rules --query "SecurityGroupRules[?GroupId=='$sgId' && !IsEgress && IpProtocol=='$protocol' && to_string(FromPort)=='$fromPort' && to_string(ToPort)=='$toPort'  && ReferencedGroupInfo.GroupId=='$referSgId'].SecurityGroupRuleId" --output text | wc -l)
                if [[ "$condition" -gt 0 ]]; then 
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando o Id de todas as regras de entrada do security group $sgName"
                    aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Removendo a regra de entrada do security group $sgName para liberação da porta $port"
                    aws ec2 revoke-security-group-ingress --group-id $sgId --ip-permissions "IpProtocol=$protocol,FromPort=$port,ToPort=$port,UserIdGroupPairs=[{GroupId=$referSgId}]" --no-cli-pager

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando o Id de todas as regras de entrada do security group $sgName"
                    aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$sgId" --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text

                else
                    echo "Não existe a regra de entrada liberando a porta $port no protocolo $protcol do security group $sgName da VPC $vpcName"
                fi
            else
                echo "Não existe o security group $sgName"
            fi
        else
            echo "Não existe o security group de referência $referSgName"
        fi            
    else
        echo "Não existe a VPC $vpcName"
    fi
else
    echo "Código não executado"
fi