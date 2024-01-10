#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "EC2 TRANSFER FILES"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2Test1"
keyPairPath="G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awsKeyPair"
keyPairName="keyPairUniversal"
awsCliPath="G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awscli/iamUserWorker"
awsCliFolder=".aws"
dockerPath="G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets"
dockerFolder=".docker"
vmPath="/home/ubuntu"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância $tagNameInstance"
    instances=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]" | wc -l)
    if [ "$instances" -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o IP público da instância de nome de tag $tagNameInstance"
        ipEc2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

        echo "Exibindo o comando para acesso remoto via OpenSSH"
        echo "ssh -i \"$keyPairPath/$keyPairName.pem\" ubuntu@$ipEc2"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se a pasta $awsCliFolder já existe na instância de nome de tag $tagNameInstance"
        folderExists=$(ssh -i "$keyPairPath/$keyPairName.pem" -o StrictHostKeyChecking=no "ubuntu@$ipEc2" "test -d \"$vmPath/$awsCliFolder\" && echo 'true' || echo 'false'")

        if [ "$folderExists" == 'true' ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "A pasta $awsCliFolder já existe na instância de nome de tag $tagNameInstance. Transferência cancelada."
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Transferindo a pasta $awsCliFolder para a instância de nome de tag $tagNameInstance"
            scp -i "$keyPairPath/$keyPairName.pem" -o StrictHostKeyChecking=no -r "$awsCliPath/$awsCliFolder" "ubuntu@$ipEc2:$vmPath"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se a pasta $dockerFolder já existe na instância de nome de tag $tagNameInstance"
        folderExists=$(ssh -i "$keyPairPath/$keyPairName.pem" -o StrictHostKeyChecking=no "ubuntu@$ipEc2" "test -d \"$vmPath/$dockerFolder\" && echo 'true' || echo 'false'")

        if [ "$folderExists" == 'true' ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "A pasta $dockerFolder já existe na instância de nome de tag $tagNameInstance. Transferência cancelada."
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Transferindo a pasta $dockerFolder para a instância de nome de tag $tagNameInstance"
            scp -i "$keyPairPath/$keyPairName.pem" -o StrictHostKeyChecking=no -r "$dockerPath/$dockerFolder" "ubuntu@$ipEc2:$vmPath"
        fi
    else
        echo "Não existe instâncias com o nome de tag $tagNameInstance"
    fi
else
    echo "Código não executado"
fi