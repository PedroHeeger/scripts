#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "TARGET GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tgName="tgTest1"
tgType="instance"
# tgType="ip"
tgProtocol="HTTP"
tgProtocolVersion="HTTP1"
tgPort=80
tgHealthCheckProtocol="HTTP"
tgHealthCheckPort="traffic-port"
tgHealthCheckPath="/"
healthyThreshold=5
unhealthyThreshold=2
hcTimeoutSeconds=5
hcIntervalSeconds=15
hcMatcher="HttpCode=200-299"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o target group $tgName"
    condition=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o target group $tgName"
        aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os target groups criados"
        aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da VPC padrão"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text)
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o target group $tgName"
        aws elbv2 create-target-group --name $tgName --target-type $tgType --protocol $tgProtocol --protocol-version $tgProtocolVersion --port $tgPort --vpc-id $vpcId --health-check-protocol $tgHealthCheckProtocol --health-check-port $tgHealthCheckPort --health-check-path $tgHealthCheckPath --healthy-threshold $healthyThreshold --unhealthy-threshold $unhealthyThreshold --health-check-timeout-seconds $hcTimeoutSeconds --health-check-interval-seconds $hcIntervalSeconds --matcher $hcMatcher --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o target group $tgName"
        aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "TARGET GROUP EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tgName="tgTest1"
albName="albTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o target group $tgName"
    condition=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os target groups criados"
        aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o load balancer $albName"
        condition=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "Necessário excluir o load balancer $albName antes de excluir o target group $tgName"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo a ARN do target group $tgName"
            tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o target group $tgName"
            aws elbv2 delete-target-group --target-group-arn $tgArn
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os target groups criados"
        aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupName" --output text
    else
        echo "Não existe o target group $tgName"
    fi
else
    echo "Código não executado"
fi