#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EBS"
echo "VOLUME CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
size=10
aZ="us-east-1a"
volumeType="gp2"
tagNameVolume="volumeEBSTest1"
awsAccountId="001727357081"
tagNameSnapshot="snapshotEBSTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o volume do EBS de tag de nome $tagNameVolume"
    if [[ $(aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o volume do EBS de tag de nome $tagNameVolume"
        aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um volume do EBS de tag de nome $tagNameVolume"
        aws ec2 create-volume --size $size --availability-zone $aZ --volume-type $volumeType --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$tagNameVolume}]" --no-cli-pager

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Extraindo o ID do snapshot do EBS de tag de nome $tagNameSnapshot"
        # snapshotId=$(aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[?Tags[?Key=='Name' && Value=='$tagNameSnapshot']].SnapshotId" --output text)

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando um volume do EBS de tag de nome $tagNameVolume a partir do snapshot de tag de nome $tagNameSnapshot"
        # aws ec2 create-volume --snapshot-id $snapshotId --size $size --availability-zone $aZ --volume-type $volumeType --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$tagNameVolume}]" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando apenas o volume do EBS de tag de nome $tagNameVolume"
        aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EBS"
echo "VOLUME EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameVolume="volumeEBSTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o volume do EBS de tag de nome $tagNameVolume"
    if [[ $(aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID do volume do EBS de tag de nome $tagNameVolume"
        volumeId=$(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe instâncias anexadas ao volume do EBS de tag de nome $tagNameVolume"
        if [[ $(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[]" --output text) ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Desanexando o volume do EBS de tag de nome $tagNameVolume da instância"
            aws ec2 detach-volume --volume-id $volumeId
        else
            echo "Não existe instâncias anexadas ao volume do EBS de tag de nome $tagNameVolume"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Aguardando o volume do EBS de tag de nome $tagNameVolume ficar disponivel"
        state=""
        while [[ "$state" != "available" ]]; do
            sleep 5
            state=$(aws ec2 describe-volumes --volume-ids $volumeId --query "Volumes[0].State" --output text)
            echo "Current state: $state"
        done

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o volume do EBS de tag de nome $tagNameVolume"
        aws ec2 delete-volume --volume-id $volumeId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text
    else
        echo "Não existe o volume do EBS de tag de nome $tagNameVolume"
    fi
else
    echo "Código não executado"
fi