#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2 E AWS ELB"
echo "INSTANCE ADD TO ELB (CLB OR ALB)"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2ELBTest1"
# elbName="albTest1"
elbName="clbTest1"
tgName="tgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == "y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe uma instância ativa $tagNameInstance"
    condition=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
    if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da instância $tagNameInstance"
        instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando o tipo de load balancer"
        isClassicLB=false
        isApplicationLB=false
        classicLB=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text)
        applicationLB=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text)
        if [[ $(echo "$classicLB" | wc -w) -gt 0 ]]; then
            isClassicLB=true
        elif [[ $(echo "$applicationLB" | wc -w) -gt 0 ]]; then
            isApplicationLB=true
        fi

        if $isClassicLB; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se a instância $tagNameInstance está associada ao classic load balancer $elbName"
            condition=$(aws elb describe-load-balancers --load-balancer-name "$elbName" --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text)
            if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe a instância $tagNameInstance associada ao classic load balancer $elbName"
                aws elb describe-load-balancers --load-balancer-name "$elbName" --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todas as instâncias associadas ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name "$elbName" --query "InstanceStates[].InstanceId" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Registrando a instância $tagNameInstance ao classic load balancer $elbName"
                aws elb register-instances-with-load-balancer --load-balancer-name "$elbName" --instances "$instanceId"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando a instância $tagNameInstance associada ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name "$elbName" --query "InstanceStates[?InstanceId=='$instanceId'].InstanceId" --output text
            fi
        elif $isApplicationLB; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o target group $tgName"
            condition=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text)
            if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo a ARN do target group $tgName"
                tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe a instância $tagNameInstance no target group $tgName"
                condition=$(aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text)
                if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Já existe a instância $tagNameInstance no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text
                else
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando todas as instâncias no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?TargetHealth.State!='draining'].Target.Id" --output text

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Registrando a instância $tagNameInstance no target group $tgName"
                    aws elbv2 register-targets --target-group-arn "$tgArn" --targets Id="$instanceId"

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando a instância $tagNameInstance no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text
                fi
            else
                echo "Não existe o target group $tgName. A instância $tagNameInstance não pôde ser adicionada. Certifique-se de criar o target group"
            fi
        else
            echo "Não existe o load balancer $elbName ou não pertence aos tipos Classic ou Application. A instância $tagNameInstance não foi vinculada ao load balancer"
        fi
    else
        echo "Não existe uma instância ativa $tagNameInstance"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2 E AWS ELB"
echo "INSTANCE REMOVE TO ELB (CLB OR ALB)"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2ELBTest1"
# elbName="albTest1"
elbName="clbTest1"
tgName="tgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == "y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe uma instância ativa $tagNameInstance"
    condition=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
    if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da instância $tagNameInstance"
        instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando o tipo de load balancer"
        isClassicLB=false
        isApplicationLB=false
        classicLB=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text)
        applicationLB=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text)

        if [[ $(echo "$classicLB" | wc -w) -gt 0 ]]; then 
            isClassicLB=true
        elif [[ $(echo "$applicationLB" | wc -w) -gt 0 ]]; then
            isApplicationLB=true
        fi

        if $isClassicLB; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se a instância $tagNameInstance está associada ao classic load balancer $elbName"
            condition=$(aws elb describe-load-balancers --load-balancer-name "$elbName" --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text)
            if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todas as instâncias associadas ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name "$elbName" --query "InstanceStates[].InstanceId" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo a instância $tagNameInstance associada ao classic load balancer $elbName"
                aws elb deregister-instances-from-load-balancer --load-balancer-name "$elbName" --instances "$instanceId"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todas as instâncias associadas ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name "$elbName" --query "InstanceStates[].InstanceId" --output text
            else
                echo "Não existe a instância $tagNameInstance associada ao classic load balancer $elbName"
            fi
        elif $isApplicationLB; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o target group $tgName"
            condition=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text)
            if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo a ARN do target group $tgName"
                tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe a instância $tagNameInstance no target group $tgName"
                condition=$(aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text)
                if [[ $(echo "$condition" | wc -w) -gt 0 ]]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando todas as instâncias no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?TargetHealth.State!='draining'].Target.Id" --output text

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Removendo a instância $tagNameInstance no target group $tgName"
                    aws elbv2 deregister-targets --target-group-arn "$tgArn" --targets Id="$instanceId"

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Listando todas as instâncias no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?TargetHealth.State!='draining'].Target.Id" --output text
                else
                    echo "Não existe a instância $tagNameInstance no target group $tgName"
                fi
            else
                echo "Não existe o target group $tgName."
            fi
        else
            echo "Não existe o load balancer $elbName ou não pertence aos tipos Classic ou Application"
        fi
    else
        echo "Não existe uma instância ativa $tagNameInstance"
    fi
else
    echo "Código não executado"
fi