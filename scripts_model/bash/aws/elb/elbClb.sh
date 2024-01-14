#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "CLASSIC LOAD BALANCER (CLB) CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clbName="clbTest1"
listenerProtocol="HTTP"
listenerPort="80"
instanceProtocol="HTTP"
instancePort="80"
aZ1="us-east-1a"
aZ2="us-east-1b"
groupName="default"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o classic load balancer de nome $clbName"
    if [[ $(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o classic load balancer de nome $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID do grupo de segurança"
        vpcId=$(aws ec2 describe-instances --query "Reservations[].Instances[].VpcId" --output text)
        sgId=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$groupName" --query "SecurityGroups[].GroupId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o classic load balancer de nome $clbName"
        aws elb create-load-balancer --load-balancer-name $clbName --listeners "Protocol=$listenerProtocol,LoadBalancerPort=$listenerPort,InstanceProtocol=$instanceProtocol,InstancePort=$instancePort" --availability-zones $aZ1 $aZ2 --security-groups $sgId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a verificação de integridade do classic load balancer de nome $clbName"
        aws elb configure-health-check --load-balancer-name $clbName --health-check "Target=${listenerProtocol}:${listenerPort}/index.html,Interval=15,UnhealthyThreshold=2,HealthyThreshold=5,Timeout=5"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o classic load balancer de nome $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "CLASSIC LOAD BALANCER (CLB) EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clbName="clbTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o classic load balancer de nome $clbName"
    if [[ $(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o classic load balancer de nome $clbName"
        aws elb delete-load-balancer --load-balancer-name $clbName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text
    else
        echo "Não existe o classic load balancer de nome $clbName"
    fi
else
    echo "Código não executado"
fi