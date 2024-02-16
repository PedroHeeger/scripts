#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EKS"
echo "NODE GROUP CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterEKSTest1"
nodeGroupName="nodeGroupTest1"
eksNodeGroupRoleName="eksEC2Role"
amiType="AL2_x86_64"
instanceType="t3.small"
diskSize=10
minSize=2
maxSize=2
desiredSize=2

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o node group de nome $nodeGroupName no cluster $clusterName (Ignorando erro)..."
    
    erro="ResourceNotFoundException"
    if aws eks describe-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --query "nodegroup.nodegroupName" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws eks describe-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --query "nodegroup.status" --output text)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o node group de nome $nodeGroupName no cluster $clusterName"
    excludedStatus=("ACTIVE" "CREATING" "UPDATING" "DELETE_FAILED" "0")
    if [[ " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o node group de nome $nodeGroupName no cluster $clusterName"
        aws eks describe-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --query "nodegroup.nodegroupName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os node groups do cluster $clusterName"
        aws eks list-nodegroups --cluster-name "$clusterName" --query "nodegroups" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da role $eksNodeGroupRoleName"
        eksNodeGroupRoleArn=$(aws iam list-roles --query "Roles[?RoleName=='$eksNodeGroupRoleName'].Arn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os Ids dos elementos de rede"
        subnet1Id=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ1'].SubnetId" --output text)
        subnet2Id=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ2'].SubnetId" --output text)
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um node group de nome $nodeGroupName no cluster $clusterName"
        aws eks create-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --subnets "$subnet1Id" "$subnet2Id" --instance-types "$instanceType" --ami-type "$amiType" --disk-size "$diskSize" --node-role "$eksNodeGroupRoleArn" --capacity-type "ON_DEMAND" --scaling-config "minSize=$minSize,maxSize=$maxSize,desiredSize=$desiredSize" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o node group de nome $nodeGroupName no cluster $clusterName"
        aws eks describe-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --query "nodegroup.nodegroupName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EKS"
echo "NODE GROUP EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterEKSTest1"
nodeGroupName="nodeGroupTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o node group de nome $nodeGroupName no cluster $clusterName (Ignorando erro)..."
    
    erro="ResourceNotFoundException"
    if aws eks describe-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --query "nodegroup.nodegroupName" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws eks describe-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --query "nodegroup.status" --output text)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o node group de nome $nodeGroupName no cluster $clusterName"
    excludedStatus=("ACTIVE" "CREATING" "UPDATING" "DELETE_FAILED" "0")
    if [[ " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os node groups do cluster $clusterName"
        aws eks list-nodegroups --cluster-name "$clusterName" --query "nodegroups" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o node group de nome $nodeGroupName do cluster $clusterName"
        aws eks delete-nodegroup --cluster-name "$clusterName" --nodegroup-name "$nodeGroupName" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os node groups do cluster $clusterName"
        aws eks list-nodegroups --cluster-name "$clusterName" --query "nodegroups" --output text
    else
        echo "Não existe o node group de nome $nodeGroupName no cluster $clusterName"
    fi
else
    echo "Código não executado"
fi