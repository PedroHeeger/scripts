#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-AUTO SCALING"
echo "SIMPLE SCALING POLICY DOBULE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
asScalingPolicyName1="asScalingPolicy1"
asScalingPolicyName2="asScalingPolicy2"
asgName="asgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
    if [[ $(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a simple scaling policy de nome $asScalingPolicyName1 no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $asScalingPolicyName1 --auto-scaling-group-name $asgName --policy-type SimpleScaling --scaling-adjustment 1 --adjustment-type "ChangeInCapacity" --cooldown 300

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a simple scaling policy de nome $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $asScalingPolicyName2 --auto-scaling-group-name $asgName --policy-type SimpleScaling --scaling-adjustment -1 --adjustment-type "ChangeInCapacity" --cooldown 300

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-AUTO SCALING"
echo "SIMPLE SCALING POLICY DOUBLE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
asScalingPolicyName1="asScalingPolicy1"
asScalingPolicyName2="asScalingPolicy2"
asgName="asgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
    if [[ $(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$asScalingPolicyName1' || PolicyName=='$asScalingPolicyName2'].PolicyName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo as simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $asScalingPolicyName1
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $asScalingPolicyName2

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as simple scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='SimpleScaling'].PolicyName[]" --output text
    else
        echo "Não existe uma das simple scaling policies de nomes $asScalingPolicyName1 e $asScalingPolicyName2 no auto scaling group $asgName"
    fi
else
    echo "Código não executado"
fi