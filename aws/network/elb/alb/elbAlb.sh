#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "APPLICATION LOAD BALANCER (ALB) CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
albName="albTest1"
aZ1="us-east-1a"
aZ2="us-east-1b"
sgName="default"
type="application"
scheme="internet-facing"
ipAddressType="ipv4"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o load balancer $albName"
    condition=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o load balancer $albName"
        aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os load balancers criados"
        aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os elementos de rede"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text)
        subnetId1=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        subnetId2=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        sgId=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupId" --output text)
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o load balancer $albName"
        aws elbv2 create-load-balancer --name $albName --type $type --scheme $scheme --ip-address-type $ipAddressType --subnets $subnetId1 $subnetId2 --security-groups $sgId --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o load balancer $albName"
        aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "APPLICATION LOAD BALANCER (ALB) EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
albName="albTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o load balancer $albName"
    condition=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os load balancers criados"
        aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do load balancer $albName"
        lbArn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o load balancer $albName"
        aws elbv2 delete-load-balancer --load-balancer-arn $lbArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os load balancers criados"
        aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName" --output text
    else
        echo "Não existe o load balancer $albName"
    fi
else
    echo "Código não executado"
fi