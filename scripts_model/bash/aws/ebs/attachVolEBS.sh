#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EBS"
echo "ATTACH VOLUME"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameVolume="volumeEBSTest1"
# deviceName="/dev/sdf"
deviceName="/dev/xvdf"
tagNameInstance="ec2Test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o volume do EBS de tag de nome $tagNameVolume"
    if [[ $(aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da instância de nome de tag $tagNameInstance"
        instanceId1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se o volume do EBS de tag de nome $tagNameVolume está anexado a instância de tag de nome $tagNameInstance"
        if [[ $(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId" --output text) ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já está anexado o volume do EBS de tag de nome $tagNameVolume a instância de tag de nome $tagNameInstance"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o ID de todas as instâncias anexadas ao volume do EBS de tag de nome $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[].InstanceId" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID do volume do EBS de tag de nome $tagNameVolume"
            volumeId=$(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Anexado o volume do EBS de tag de nome $tagNameVolume a instância de nome de tag $tagNameInstance"
            aws ec2 attach-volume --volume-id $volumeId --instance-id $instanceId1 --device $deviceName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando apenas a instância de tag de nome $tagNameInstance anexada ao volume do EBS de tag de nome $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId" --output text
        fi
    else
        echo "Não existe o volume do EBS de tag de nome $tagNameVolume"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EBS"
echo "DETACH VOLUME"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameVolume="volumeEBSTest1"
tagNameInstance="ec2Test1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o volume do EBS de tag de nome $tagNameVolume"
    if [[ $(aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da instância de nome de tag $tagNameInstance"
        instanceId1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se o volume do EBS de tag de nome $tagNameVolume está anexado a instância de tag de nome $tagNameInstance"
        if [[ $(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId" --output text) ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o ID de todas as instâncias anexadas ao volume do EBS de tag de nome $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[].InstanceId" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID do volume do EBS de tag de nome $tagNameVolume"
            volumeId=$(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Desanexando o volume do EBS de tag de nome $tagNameVolume da instância de tag de nome $tagNameInstance"
            aws ec2 detach-volume --volume-id $volumeId

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Aguardando o volume do EBS de tag de nome $tagNameVolume ficar disponível"
            state=""
            while [[ "$state" != "available" ]]; do
                sleep 5
                state=$(aws ec2 describe-volumes --volume-ids $volumeId --query "Volumes[0].State" --output text)
                echo "Current state: $state"
            done

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o ID de todas as instâncias anexadas ao volume do EBS de tag de nome $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[].InstanceId" --output text
        else
            echo "Não está anexado o volume do EBS de tag de nome $tagNameVolume a instância de nome de tag $tagNameInstance"
        fi
    else
        echo "Não existe o volume do EBS de tag de nome $tagNameVolume"
    fi
else
    echo "Código não executado"
fi