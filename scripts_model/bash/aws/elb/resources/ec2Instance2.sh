#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance2="ec2Test2"
groupName="default"
availabilityZone="us-east-1a"
imageId="ami-0fc5d935ebf8bc3bc"
instanceType="t2.micro"
keyPairName="keyPairTest"
userDataPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\bash\aws\elb\resources\"
userDataFile="udFileTest.sh"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance2"
    if [ "$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[]" | jq length)" -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma instância EC2 com o nome de tag $tagNameInstance2"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='$tagNameInstance2'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o IP público da instância $tagNameInstance2"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os Ids do grupo de segurança e sub-redes padrões"
        securityGroupId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text)
        subnetId=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$availabilityZone'].SubnetId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a instância EC2 de nome de tag $tagNameInstance2"
        aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $securityGroupId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath/$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tagNameInstance2}]" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o IP público da instância $tagNameInstance2"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
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
tagNameInstance2="ec2Test2"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance2"
    if [ "$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[]" | jq length)" -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da instância de nome de tag $tagNameInstance2"
        instanceId1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a instância de nome de tag $tagNameInstance2"
        aws ec2 terminate-instances --instance-ids $instanceId1 --no-dry-run --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    else
        echo "Não existe instâncias com o nome de tag $tagNameInstance2"
    fi
else
    echo "Código não executado"
fi