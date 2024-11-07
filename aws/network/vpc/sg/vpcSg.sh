#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "SECURITY GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
sgName="sgTest1"
# sgName="default"
vpcName="vpcTest1"
# vpcName="default"
sgDescription="Security Group Test1"
sgTagName="sgTest1"

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
            echo "Já existe o security group $sgName na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os security groups criados na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" --query "SecurityGroups[].GroupName" --output text
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o security group $sgName na VPC $vpcName"
            aws ec2 create-security-group --group-name $sgName --description "$sgDescription" --vpc-id $vpcId --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$sgTagName}]"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o security group $sgName na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupName" --output text
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
echo "SECURITY GROUP EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
sgName="sgTest1"
# sgName="default"
vpcName="vpcTest1"
# vpcName="default"

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
            echo "Listando todos os security groups criados na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" --query "SecurityGroups[].GroupName" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id do security group $sgName da VPC $vpcName"
            sgId=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupId" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o security group $sgName da VPC $vpcName"
            aws ec2 delete-security-group --group-id $sgId

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os security groups criados na VPC $vpcName"
            aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" --query "SecurityGroups[].GroupName" --output text
        else
            echo "Não existe o security group $sgName na VPC $vpcName"
        fi
    else
        echo "Não existe a VPC $vpcName"
    fi
else
    echo "Código não executado"
fi