#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2 E AWS ROUTE 53"
echo "TWO INSTANCE CREATION FOR ROUTE 53"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2Test"
instanceA="1"
instanceB="2"
az="us-east-1a"
otherAZ="sa-east-1a"
sgName="default"
imageIdA="ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
imageIdB="ami-0f16d0d3ac759edfa"    # Canonical, Ubuntu, 24.04, amd64 noble image
so="ubuntu"
# so="ec2-user"
instanceType="t2.micro"
keyPairPathA="G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
keyPairNameA="keyPairUniversal"
keyPairPathB="G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/test"
keyPairNameB="keyPairTest"
userDataPath="G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd/"
userDataFile="udFileDeb.sh"
# deviceName="/dev/xvda" 
deviceName="/dev/sda1"
volumeSize=8
volumeType="gp2"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == "y" ]]; then
    CreateEC2Instance() {tagNameInstance="$1" instanceNum="$2" region="$3" keyPairPath="$4" keyPairName="$5" so="$6" sgName="$7" az="$8" imageId="$9" instanceType="${10}" userDataPath="${11}" userDataFile="${12}" deviceName="${13}" volumeSize="${14}" volumeType="${15}"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a instância ativa ${tagNameInstance}${instanceNum}"
        condition=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceNum}')])].[Tags[?Key=='Name'].Value | [0]]" --region "$region" --output text)
        if [[ $(echo "$condition" | wc -l) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe as instâncias ativas ${tagNameInstance}${instanceNum}"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceNum}'].Value" --region "$region" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o IP público da instância ativa ${tagNameInstance}${instanceNum}"
            instanceIp=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region "$region" --output text)
            echo "$instanceIp"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id da instância ativa ${tagNameInstance}${instanceNum}"
            instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceNum}"
            echo "ssh -i \"$keyPairPath/$keyPairName.pem\" $so@$instanceIp"
            echo "aws ssm start-session --target $instanceId"
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region "$region" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id dos elementos de rede para a instância ${tagNameInstance}${instanceNum}"
            sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --region "$region" --output text)
            subnetId=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$az'].SubnetId" --region "$region" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando a instância ${tagNameInstance}${instanceNum}"
            instanceId=$(aws ec2 run-instances --image-id "$imageId" --instance-type "$instanceType" --key-name "$keyPairName" --security-group-ids "$sgId" --subnet-id "$subnetId" --count 1 --user-data "file://$userDataPath/$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${tagNameInstance}${instanceNum}}]" --block-device-mappings "[{\"DeviceName\":\"$deviceName\",\"Ebs\":{\"VolumeSize\":$volumeSize,\"VolumeType\":\"$volumeType\"}}]" --no-cli-pager --query "Instances[0].InstanceId" --region "$region" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Aguardando a instância criada entrar em execução"
            instanceState=""
            while [[ "$instanceState" != "running" ]]; do
                sleep 20  
                instanceState=$(aws ec2 describe-instances --instance-ids "$instanceId" --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager)
                echo "Estado atual da instância ${tagNameInstance}${instanceNum}: $instanceState"
            done

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region "$region" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o IP público das instâncias ativas ${tagNameInstance}${instanceNum}"
            instanceIp=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region "$region" --output text)
            echo "$instanceIp"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id das instâncias ativas ${tagNameInstance}${instanceNum}"
            instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceNum}"
            echo "ssh -i \"$keyPairPath/$keyPairName.pem\" $so@$instanceIp"
            echo "aws ssm start-session --target $instanceId"
        fi
    }

    if [[ "$instanceA" -lt "$instanceB" ]]; then
        region="${az:0:${#az}-1}"
        CreateEC2Instance "$tagNameInstance" "$instanceA" "$region" "$keyPairPathA" "$keyPairNameA" "$so" "$sgName" "$az" "$imageIdA" "$instanceType" "$userDataPath" "$userDataFile" "$deviceName" "$volumeSize" "$volumeType"
    if [[ "$instanceB" -gt "$instanceA" ]]; then
        region="${otherAZ:0:${#otherAZ}-1}"
        CreateEC2Instance "$tagNameInstance" "$instanceB" "$region" "$keyPairPathB" "$keyPairNameB" "$so" "$sgName" "$otherAZ" "$imageIdB" "$instanceType" "$userDataPath" "$userDataFile" "$deviceName" "$volumeSize" "$volumeType"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2 E AWS ROUTE 53"
echo "TWO INSTANCE EXCLUSION FOR ROUTE 53"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2Test"
instanceA="1"
instanceB="2"
az="us-east-1a"
otherAZ="sa-east-1a"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == "y" ]]; then
    DeleteEC2Instance() {tagNameInstance="$1" instanceNum="$2" region="$3"
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a instância ativa ${tagNameInstance}${instanceNum}"
        condition=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceNum}')])].[Tags[?Key=='Name'].Value | [0]]" --region "$region" --output text)
        if [[ ${#condition} -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region "$region" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o Id da instância ativa ${tagNameInstance}${instanceNum}"
            instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo a instância ${tagNameInstance}${instanceNum}"
            aws ec2 terminate-instances --instance-ids "$instanceId" --no-dry-run --region "$region" --no-cli-pager

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Aguardando a instância ser removida"
            instanceState=""
            while [[ "$instanceState" != "terminated" ]]; do
                sleep 20
                instanceState=$(aws ec2 describe-instances --instance-ids "$instanceId" --query "Reservations[].Instances[].State.Name" --region "$region" --output text --no-cli-pager)
                echo "Estado atual da instância ${tagNameInstance}${instanceNum}: $instanceState"
            done

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region "$region" --output text
        else
            echo "Não existe a instância ativa ${tagNameInstance}${instanceNum}"
        fi
    }

    if [[ "$instanceA" -lt "$instanceB" ]]; then
        region="${az:0:${#az}-1}"
        DeleteEC2Instance "$tagNameInstance" "$instanceA" "$region"
    fi
    if [[ "$instanceB" -gt "$instanceA" ]]; then
        region="${otherAZ:0:${#otherAZ}-1}"
        DeleteEC2Instance "$tagNameInstance" "$instanceB" "$region"
    fi
else
    echo "Código não executado"
fi