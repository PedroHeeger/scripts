#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "LISTENER RULE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
albName="albTest1"
tgName="tgTest1"
listenerProtocol="HTTP"
listenerPort="80"
redirectProtocol="HTTPS"
redirectPort=443
listenerRuleName="listenerRuleTest1"

read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do load balancer $albName"
    lbArn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do target group $tgName"
    tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
    if [ $(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do listener cujo protocolo é $listenerProtocol e a porta é $listenerPort"
        listenerArn=$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
        if [ $(aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as regras do listener de protocolo $listenerProtocol e porta $listenerPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[].RuleArn" --output text
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 create-rule --listener-arn $listenerArn --conditions "Field=path-pattern,Values=['/']" --priority 1 --actions "Type=redirect,RedirectConfig={Protocol=$redirectProtocol,Port=$redirectPort,StatusCode=HTTP_301}" --tags "Key=Name,Value=$listenerRuleName" --no-cli-pager
    
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text
        fi
    else
        echo "Não existe um listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "LISTENER RULE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
albName="albTest1"
tgName="tgTest1"
listenerProtocol="HTTP"
listenerPort="80"
redirectProtocol="HTTPS"
redirectPort=443

read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do load balancer $albName"
    lbArn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do target group $tgName"
    tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
    if [ $(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do listener cujo protocolo é $listenerProtocol e a porta é $listenerPort"
        listenerArn=$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
        if [ $(aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as regras do listener de protocolo $listenerProtocol e porta $listenerPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[].RuleArn" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo a ARN da regra do listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            listenerRuleArn=$(aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo a regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 delete-rule --rule-arn $listenerRuleArn

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as regras do listener de protocolo $listenerProtocol e porta $listenerPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[].RuleArn" --output text
        else
            echo "Não existe a regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
        fi
    else
        echo "Não existe um listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
    fi
else
    echo "Código não executado"
fi