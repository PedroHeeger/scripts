#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "LISTENER CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
albName="albTest1"
tgName="tgTest1"
listenerProtocol="HTTP"
listenerPort="80"
# listenerProtocol="HTTPS"
# listenerPort="443"
fullDomainName="www.pedroheeger.dev.br"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o target group $tgName e o load balancer $albName"
    condition=$( (aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text | wc -l) -gt 0 && (aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do load balancer $albName"
        lbArn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do target group $tgName"
        tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
        condition=$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os listeners do load balancer $albName"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text

            if [[ "$listenerProtocol" == "HTTPS" ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo a ARN do certificado de domínio $fullDomainName"
                certificateArn = $(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$fullDomainName'].CertificateArn" --output text)
                
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Criando um listener para vincular o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol com certificado"
                aws elbv2 create-listener --load-balancer-arn $lbArn --protocol $listenerProtocol --port $listenerPort --default-actions "Type=forward,TargetGroupArn=$tgArn" --certificates CertificateArn=$certificateArn --no-cli-pager
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Criando um listener para vincular o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
                aws elbv2 create-listener --load-balancer-arn $lbArn --protocol $listenerProtocol --port $listenerPort --default-actions "Type=forward,TargetGroupArn=$tgArn" --no-cli-pager
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text
    else
        echo "Não existe o target group $tgName ou o load balancer $albName"
    fi           
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "LISTENER EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
albName="albTest1"
tgName="tgTest1"
listenerProtocol="HTTP"
listenerPort="80"
# listenerProtocol="HTTPS"
# listenerPort="443"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o target group $tgName e o load balancer $albName"
    condition=$( (aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text | wc -l) -gt 0 && (aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do load balancer $albName"
        lbArn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN do target group $tgName"
        tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
        condition=$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os listeners do load balancer $albName"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo a ARN do listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            listenerArn=$(aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            aws elbv2 delete-listener --listener-arn $listenerArn

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os listeners do load balancer $albName"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
        else
            echo "Não existe um listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
        fi
    else
        echo "Não existe o target group $tgName ou o load balancer $albName"
    fi      
else
    echo "Código não executado"
fi