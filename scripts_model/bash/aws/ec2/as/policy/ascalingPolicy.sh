#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-AUTO SCALING"
echo "SIMPLE SCALING POLICY CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
asScalingPolicyName="asScalingPolicy1"
asgName="asgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
    
    if [[ $(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $asScalingPolicyName --auto-scaling-group-name $asgName --policy-type SimpleScaling --scaling-adjustment 1 --adjustment-type "ChangeInCapacity" --cooldown 300

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-AUTO SCALING"
echo "SIMPLE SCALING POLICY EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
asScalingPolicyName="asScalingPolicy1"
asgName="asgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
    
    if [[ $(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName'].PolicyName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os auto scaling groups existentes"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[].PolicyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $asScalingPolicyName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os auto scaling groups existentes"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[].PolicyName" --output text
    else
        echo "Não existe a simple scaling policy de nome $asScalingPolicyName no auto scaling group $asgName"
    fi
else
    echo "Código não executado"
fi