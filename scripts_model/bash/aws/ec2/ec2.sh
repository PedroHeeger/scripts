#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2Test"
groupName="default"
availabilityZone="us-east-1a"
imageId="ami-0fc5d935ebf8bc3bc"
instanceType="t2.micro"
keyPairName="keyPair1"
userDataPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\bash\.default\test"
userDataFile="userDataFile.sh"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance"
    if [ "$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]" | jq length)" -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma instância EC2 com o nome de tag $tagNameInstance"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='$tagNameInstance'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o IP público da instância $tagNameInstance"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os Ids do grupo de segurança e sub-redes padrões"
        securityGroupId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text)
        subnetId=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$availabilityZone'].SubnetId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a instância EC2 de nome de tag $tagNameInstance"
        aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $securityGroupId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath/$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tagNameInstance}]" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o IP público da instância $tagNameInstance"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "EC2 EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2Test"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance"
    if [ "$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]" | jq length)" -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da instância de nome de tag $tagNameInstance"
        instanceId1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a instância de nome de tag $tagNameInstance"
        aws ec2 terminate-instances --instance-ids $instanceId1 --no-dry-run --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    else
        echo "Não existe instâncias com o nome de tag $tagNameInstance"
    fi
else
    echo "Código não executado"
fi