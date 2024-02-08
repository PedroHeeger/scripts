#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2Test1"
sgName="default"
aZ="us-east-1a"
imageId="ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
instanceType="t2.micro"
keyPairPath="G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awsKeyPair"
keyPairName="keyPairUniversal"
userDataPath="G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/basic"
userDataFile="udFile.sh"
# device_dame="/dev/xvda" 
device_name="/dev/sda1"
volumeSize=8
volumeType="gp2"
instanceProfileName="instanceProfileTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance"
    if [ "$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]" --output text | wc -l)" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma instância EC2 com o nome de tag $tagNameInstance"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='$tagNameInstance'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o IP público da instância $tagNameInstance"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Exibindo o comando para acesso remoto via OpenSSH"
        ipEc2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)
        echo "ssh -i \"$keyPairPath/$keyPairName.pem\" ubuntu@$ipEc2"
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os Ids do grupo de segurança e sub-redes padrões"
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)
        subnetId=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ'].SubnetId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a instância EC2 de nome de tag $tagNameInstance"
        aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $sgId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath/$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tagNameInstance}]" --block-device-mappings "[{\"DeviceName\":\"$deviceName\",\"Ebs\":{\"VolumeSize\":$volumeSize,\"VolumeType\":\"$volumeType\"}}]" --no-cli-pager

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando a instância EC2 de nome de tag $tagNameInstance"
        # aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $sgId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath/$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tagNameInstance}]" --block-device-mappings "[{\"DeviceName\":\"$deviceName\",\"Ebs\":{\"VolumeSize\":$volumeSize,\"VolumeType\":\"$volumeType\"}}]" --iam-instance-profile Name=instance_profile_name --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o IP público da instância $tagNameInstance"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Exibindo o comando para acesso remoto via OpenSSH"
        ipEc2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)
        echo "ssh -i \"$keyPairPath/$keyPairName.pem\" ubuntu@$ipEc2"
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
tagNameInstance="ec2Test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance"
    if [ "$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]" --output text | wc -l)" -gt 1 ]; then
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