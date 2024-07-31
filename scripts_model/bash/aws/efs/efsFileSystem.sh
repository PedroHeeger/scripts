#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EFS"
echo "FILE SYSTEM CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
efsToken="fsTokenEFSTest1"
tagNameFS="fsEFSTest1"
performanceMode="generalPurpose"
throughputMode="bursting"
aZ="us-east-1a"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" = "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o sistema de arquivos de tag de nome $tagNameFS"
    if [ $(aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o sistema de arquivos de tag de nome $tagNameFS"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a tag de nome de todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o sistema de arquivos de tag de nome $tagNameFS"
        aws efs create-file-system --creation-token $efsToken --performance-mode $performanceMode --throughput-mode $throughputMode --tags Key=Name,Value=$tagNameFS --no-cli-pager

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando o sistema de arquivos de tag de nome $tagNameFS"
        # aws efs create-file-system --creation-token $efsToken --performance-mode $performanceMode --throughput-mode $throughputMode --availability-zone-name $aZ --tags Key=Name,Value=$tagNameFS --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando apenas o sistema de arquivos de tag de nome $tagNameFS"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EFS"
echo "FILE SYSTEM EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameFS="fsEFSTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o sistema de arquivos de tag de nome $tagNameFS"
    if [[ $(aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text) ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a tag de nome de todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID do sistema de arquivos de tag de nome $tagNameFS"
        fsId=$(aws efs describe-file-systems --query "FileSystems[?Tags[?Key=='Name' && Value=='$tagNameFS']].FileSystemId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existem pontos de montagem no sistema de arquivos de tag de nome $tagNameFS"
        mountTargetIds=$(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[].MountTargetId[]" --output text | tr '\t' '\n')

        if [[ $mountTargetIds ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo todos os pontos de montagem no sistema de arquivos de tag de nome $tagNameFS"
            for mountTargetId in $mountTargetIds; do
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo ponto de montagem $mountTargetId"
                aws efs delete-mount-target --mount-target-id $mountTargetId

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Aguardando a remoção do ponto de montagem $mountTargetId"
                state="deleting"
                while [[ "$state" == "creating" || "$state" == "available" || "$state" == "deleting" ]]; do
                    sleep 5
                    state=$(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?MountTargetId=='$mountTargetId'].LifeCycleState[]" --output text)
                    echo "Current state: $state"
                done
            done
        else
            echo "Não existem pontos de montagem no sistema de arquivos de tag de nome $tagNameFS"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o sistema de arquivos de tag de nome $tagNameFS"
        aws efs delete-file-system --file-system-id $fsId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a tag de nome de todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text
    else
        echo "Não existe o sistema de arquivos de tag de nome $tagNameFS"
    fi
else
    echo "Código não executado"
fi