#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EKS"
echo "CLUSTER CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterEKSTest1"
eksRoleName="eksClusterRole"
sgName="default"
aZ1="us-east-1a"
aZ2="us-east-1b"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName (Ignorando erro)..."
    
    erro="ResourceNotFoundException"
    aws eks describe-cluster --name "$clusterName" --query "cluster.status" 2>&1 | grep -q "$erro"
    if [ $? -eq 0 ]; then
        condition=0
    else
        condition=$(aws eks describe-cluster --name "$clusterName" --query "cluster.status" --output text)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    if [ "$condition" == "ACTIVE" ] || [ "$condition" == "CREATING" ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o cluster de nome $clusterName"
        aws eks describe-cluster --name "$clusterName" --query "cluster.name" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os clusters criados"
        aws eks list-clusters --query "clusters[]" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da role $eksRoleName"
        eksRoleArn=$(aws iam list-roles --query "Roles[?RoleName=='$eksRoleName'].Arn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os Ids dos elementos de rede"
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)
        subnet1Id=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ1'].SubnetId" --output text)
        subnet2Id=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ2'].SubnetId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um cluster de nome $clusterName"
        aws eks create-cluster --name "$clusterName" --role-arn "$eksRoleArn" --resources-vpc-config "subnetIds=$subnet1Id,$subnet2Id,securityGroupIds=$sgId" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o cluster de nome $clusterName"
        aws eks describe-cluster --name "$clusterName" --query "cluster.name" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EKS"
echo "CLUSTER EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
clusterName="clusterEKSTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName (Ignorando erro)..."
    
    erro="ResourceNotFoundException"
    if aws eks describe-cluster --name "$clusterName" --query "cluster.status" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws eks describe-cluster --name "$clusterName" --query "cluster.status" --output text)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o cluster de nome $clusterName"
    if [ "$condition" == "ACTIVE" ] || [ "$condition" == "CREATING" ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os clusters criados"
        aws eks list-clusters --query "clusters[]" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o cluster de nome $clusterName"
        aws eks delete-cluster --name "$clusterName" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os clusters criados"
        aws eks list-clusters --query "clusters[]" --output text
    else
        echo "Não existe o cluster de nome $clusterName"
    fi
else
    echo "Código não executado"
fi