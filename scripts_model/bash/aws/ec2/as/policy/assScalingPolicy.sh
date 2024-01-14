#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-AUTO SCALING"
echo "STEP SCALING POLICY CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
assScalingPolicyName="assScalingPolicy1"
asgName="asgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"

    if [[ $(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as step scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='StepScaling'].PolicyName[]" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling put-scaling-policy --policy-name $assScalingPolicyName --auto-scaling-group-name $asgName --policy-type StepScaling --adjustment-type "ChangeInCapacity" --cooldown 300 --step-adjustments "[
            {
                \"MetricIntervalLowerBound\": 0.0, 
                \"MetricIntervalUpperBound\": 40.0, 
                \"ScalingAdjustment\": 0
            }, {
                \"MetricIntervalLowerBound\": 40.0, 
                \"MetricIntervalUpperBound\": 90.0, 
                \"ScalingAdjustment\": 1
            }, {
                \"MetricIntervalLowerBound\": 90.0,
                \"ScalingAdjustment\": 2
            }]"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2-AUTO SCALING"
echo "STEP SCALING POLICY EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
assScalingPolicyName="assScalingPolicy1"
asgName="asgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
    if [[ $(aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyName=='$assScalingPolicyName'].PolicyName" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as step scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='StepScaling'].PolicyName[]" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
        aws autoscaling delete-policy --auto-scaling-group-name $asgName --policy-name $assScalingPolicyName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as step scaling policies do auto scaling group $asgName"
        aws autoscaling describe-policies --auto-scaling-group-name $asgName --query "ScalingPolicies[?PolicyType=='StepScaling'].PolicyName[]" --output text
    else
        echo "Não existe a step scaling policy de nome $assScalingPolicyName no auto scaling group $asgName"
    fi
else
    echo "Código não executado"
fi