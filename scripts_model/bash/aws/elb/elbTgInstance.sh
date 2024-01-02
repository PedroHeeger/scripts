#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "TARGET GROUP ADD INSTANCE EC2"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tgName="tgTest1"
tagNameInstance="ec2Test"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do target group $tgName"
    tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo o Id da instância $tagNameInstance"
    instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance no target group $tgName"
    if [ $(aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a instância $tagNameInstance no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[]"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Registrando a instância $tagNameInstance no target group $tgName"
        aws elbv2 register-targets --target-group-arn $tgArn --targets Id=$instanceId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a instância $tagNameInstance no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-ELB"
echo "TARGET GROUP REMOVE INSTANCE EC2"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tgName="tgTest1"
tagNameInstance="ec2Test"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo a ARN do target group $tgName"
    tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Extraindo o Id da instância $tagNameInstance"
    instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance no target group $tgName"

    if [ $(aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a instância $tagNameInstance no target group $tgName"
        aws elbv2 deregister-targets --target-group-arn $tgArn --targets Id=$instanceId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias no target group $tgName"
        aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[].Target.Id" --output text
    else
        echo "Não existe o target group de nome $tgName"
    fi
else
    echo "Código não executado"
fi