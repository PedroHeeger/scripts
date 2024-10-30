#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EBS"
echo "SNAPSHOT CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
awsAccountId="001727357081"
tagNameVolume="volumeEBSTest1"
snapshotDescription="Snapshot Description Test 1"
tagNameSnapshot="snapshotEBSTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o volume do EBS $tagNameVolume"
    condition=$(aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o snapshot $tagNameSnapshot"
        condition=$(aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o snapshot $tagNameSnapshot"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os snapshots do EBS criado da conta especificada"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].SnapshotId" --output text
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID do volume do EBS $tagNameVolume"
            volumeId=$(aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o snapshot $tagNameSnapshot a partir do volume do EBS $tagNameVolume"
            aws ec2 create-snapshot --volume-id $volumeId --description "$snapshotDescription" --tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=$tagNameSnapshot}]" --no-cli-pager

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Aguardando o snapshot $tagNameVolume ser concluído"
            state=""
            while [[ "$state" != "completed" ]]; do
                sleep 10
                state=$(aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[?Tags[?Key=='Name' && Value=='$tagNameSnapshot']].State" --output text)
                echo "Current state: $state"
            done            

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando apenas o snapshot do EBS $tagNameSnapshot"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text
        fi
    else
        echo "Não existe o volume do EBS $tagNameVolume"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EBS"
echo "SNAPSHOT EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
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
        echo "Verificando se existe o snapshot $tagNameSnapshot"
        condition=$(aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os snapshots do EBS criado da conta especificada"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].SnapshotId" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID do snapshot do EBS $tagNameSnapshot"
            snapshotId=$(aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[?Tags[?Key=='Name' && Value=='$tagNameSnapshot']].SnapshotId" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o snapshot do EBS $tagNameSnapshot"
            aws ec2 delete-snapshot --snapshot-id $snapshotId

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os snapshots do EBS criado da conta especificada"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].SnapshotId" --output text
        else
            echo "Não existe o snapshot do EBS $tagNameSnapshot"
        fi
    else
        echo "Não existe o volume do EBS $tagNameVolume"
    fi
else
    echo "Código não executado"
fi