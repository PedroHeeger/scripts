#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "LISTENER CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
lbName="lbTest1"
tgName="tgTest1"
protocol="HTTP"
port="80"

read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do load balancer $lbName"
    lbArn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$lbName'].LoadBalancerArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do target group $tgName"
    tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

    condition=$([ "$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" | wc -l)" -gt 1 ] && [ "$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].DefaultActions[?TargetGroupArn=='$tgArn']" | wc -l)" -gt 1 ])

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe um listener vinculando o target group $tgName ao load balancer $lbName"
    if [ "$condition" = true ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe um listener vinculando o target group $tgName ao load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os listeners do load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um listener para vincular o target group $tgName ao load balancer $lbName"
        aws elbv2 create-listener --load-balancer-arn $lbArn --protocol $protocol --port $port --default-actions "Type=forward,TargetGroupArn=$tgArn" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o listener que vincula o target group $tgName ao load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "LISTENER EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
lbName="lbTest1"
tgName="tgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do load balancer $lbName"
    lbArn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$lbName'].LoadBalancerArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do target group $tgName"
    tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

    condition=$(
        [ $(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" | jq length) -gt 1 ] &&
        [ $(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].DefaultActions[?TargetGroupArn=='$tgArn']" | jq length) -gt 1 ]
    )

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe um listener vinculando o target group $tgName ao load balancer $lbName"
    if [ $condition -eq 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os listeners do load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do listener que vincula o target group $tgName ao load balancer $lbName"
        listenerArn=$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo listener que vincula o target group $tgName ao load balancer $lbName"
        aws elbv2 delete-listener --listener-arn $listenerArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os listeners do load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    else
        echo "Não existe um listener que vincula o target group $tgName ao load balancer $lbName"
    fi
else
    echo "Código não executado"
fi