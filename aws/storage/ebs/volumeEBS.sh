#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EBS"
echo "VOLUME CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
size=10
az="us-east-1a"
volumeType="gp2"
tagNameVolume="volumeEBSTest1"
awsAccountId="001727357081"
tagNameSnapshot="snapshotEBSTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o volume do EBS $tagNameVolume"
    condition=$(aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o volume do EBS $tagNameVolume"
        aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o volume do EBS $tagNameVolume"
        aws ec2 create-volume --size $size --availability-zone $az --volume-type $volumeType --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$tagNameVolume}]" --encrypted --no-cli-pager

        # Descomente as linhas abaixo se precisar criar um volume a partir de um snapshot e comente a linha de criação acima
        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Verificando se existe o snapshot $tagNameSnapshot"
        # condition=$(aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text | wc -l)
        # if [[ "$condition" -gt 0 ]]; then
            # echo "-----//-----//-----//-----//-----//-----//-----"
            # echo "Extraindo o ID do snapshot do EBS $tagNameSnapshot"
            # snapshotId=$(aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[?Tags[?Key=='Name' && Value=='$tagNameSnapshot']].SnapshotId" --output text)

            # echo "-----//-----//-----//-----//-----//-----//-----"
            # echo "Criando o volume do EBS $tagNameVolume a partir do snapshot $tagNameSnapshot"
            # aws ec2 create-volume --snapshot-id $snapshotId --size $size --availability-zone $az --volume-type $volumeType --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$tagNameVolume}]" --encrypted --no-cli-pager
        # else
        #     echo "Não existe o volume do EBS $tagNameVolume"
        # fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando apenas o volume do EBS $tagNameVolume"
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
    echo "Verificando se existe o volume do EBS $tagNameVolume"
    condition=$(aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID do volume do EBS $tagNameVolume"
        volumeId=$(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe instâncias anexadas ao volume do EBS $tagNameVolume"
        if [[ $(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[]" --output text) ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Desanexando o volume do EBS $tagNameVolume da instância"
            aws ec2 detach-volume --volume-id $volumeId
        else
            echo "Não existe instâncias anexadas ao volume do EBS $tagNameVolume"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Aguardando o volume do EBS $tagNameVolume ficar disponivel"
        state=""
        while [[ "$state" != "available" ]]; do
            sleep 5
            state=$(aws ec2 describe-volumes --volume-ids $volumeId --query "Volumes[0].State" --output text)
            echo "Current state: $state"
        done

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o volume do EBS $tagNameVolume"
        aws ec2 delete-volume --volume-id $volumeId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text
    else
        echo "Não existe o volume do EBS $tagNameVolume"
    fi
else
    echo "Código não executado"
fi