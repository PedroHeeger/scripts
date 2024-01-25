#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "VPC CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# vpcName="vpcTest1"
vpcName="default"
cidrBlock="10.0.0.0/24"

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
    echo "Verificando se existe a VPC de nome $vpcName"
    if [ $(aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a VPC de nome $vpcName"
        aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as VPCs existentes"
        aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a VPC de nome $vpcName"
        aws ec2 create-vpc --cidr-block $cidrBlock --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$vpcName}]" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a VPC de nome $vpcName"
        aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-VPC"
echo "VPC EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
vpcName="vpcTest1"
cidrBlock="10.0.0.0/24"

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
    echo "Verificando se existe a VPC de nome $vpcName"
    if [ $(aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as VPCs existentes"
        aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC de nome $vpcName"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=$condition,Values=$vpcNameControl" --query "Vpcs[].VpcId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a VPC de nome $vpcName"
        aws ec2 delete-vpc --vpc-id $vpcId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as VPCs existentes"
        aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text
    else
        echo "Não existe a VPC de nome $vpcName"
    fi
else
    echo "Código não executado"
fi