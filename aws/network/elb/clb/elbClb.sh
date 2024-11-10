#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "CLASSIC LOAD BALANCER (CLB) CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clbName="clbTest1"
listenerProtocol="HTTP"
listenerPort="80"
instanceProtocol="HTTP"
instancePort="80"
az1="us-east-1a"
az2="us-east-1b"
sgName="default"
hcProtocol="HTTP"
hcPort="80"
hcPath="index.html"
hcIntervalSeconds=15
unhealthyThreshold=2
healthyThreshold=5
hcTimeoutSeconds=5

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o classic load balancer $clbName"
    condition=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o classic load balancer $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID dos elementos de rede"
        vpcId=$(aws ec2 describe-instances --query "Reservations[].Instances[].VpcId" --output text)
        sgId=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o classic load balancer $clbName"
        aws elb create-load-balancer --load-balancer-name $clbName --listeners "Protocol=$listenerProtocol,LoadBalancerPort=$listenerPort,InstanceProtocol=$instanceProtocol,InstancePort=$instancePort" --availability-zones $az1 $az2 --security-groups $sgId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a verificação de integridade do classic load balancer $clbName"
        aws elb configure-health-check --load-balancer-name "$clbName" --health-check "Target=${hcProtocol}:${hcPort}/${hcPath},Interval=${hcIntervalSeconds},UnhealthyThreshold=${unhealthyThreshold},HealthyThreshold=${healthyThreshold},Timeout=${hcTimeoutSeconds}"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o classic load balancer $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ELB"
echo "CLASSIC LOAD BALANCER (CLB) EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clbName="clbTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o classic load balancer $clbName"
    condition=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o classic load balancer $clbName"
        aws elb delete-load-balancer --load-balancer-name $clbName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text
    else
        echo "Não existe o classic load balancer $clbName"
    fi
else
    echo "Código não executado"
fi