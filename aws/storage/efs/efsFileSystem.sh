#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EFS"
echo "FILE SYSTEM CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
efsToken="fsTokenEFSTest1"
tagNameFS="fsEFSTest1"
performanceMode="generalPurpose"   # Modo padrão adequado para a maioria das cargas de trabalho, oferecendo latência moderada e desempenho equilibrado.
# performanceMode="maxIO"            # Otimizado para cargas de trabalho de alta taxa de I/O, oferecendo maior throughput e latência mais consistente para aplicações que demandam alto desempenho.
throughputMode="bursting"          # Modo padrão que permite picos de throughput acima do nível base usando créditos acumulados, adequado para cargas de trabalho com variação no uso.
# throughputMode="provisioned"       # Permite configurar um nível fixo de throughput, garantindo capacidade constante para cargas de trabalho com requisitos de I/O consistentes.
aZ="us-east-1a"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" = "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o sistema de arquivos $tagNameFS"
    condition=$(aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o sistema de arquivos $tagNameFS"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o sistema de arquivos $tagNameFS"
        aws efs create-file-system --creation-token $efsToken --performance-mode $performanceMode --throughput-mode $throughputMode --tags Key=Name,Value=$tagNameFS --encrypted --no-cli-pager

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando o sistema de arquivos $tagNameFS em uma AZ determinada"
        # aws efs create-file-system --creation-token $efsToken --performance-mode $performanceMode --throughput-mode $throughputMode --availability-zone-name $aZ --tags Key=Name,Value=$tagNameFS --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando apenas o sistema de arquivos $tagNameFS"
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
    echo "Verificando se existe o sistema de arquivos $tagNameFS"
    condition=$(aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID do sistema de arquivos $tagNameFS"
        fsId=$(aws efs describe-file-systems --query "FileSystems[?Tags[?Key=='Name' && Value=='$tagNameFS']].FileSystemId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existem pontos de montagem no sistema de arquivos $tagNameFS"
        mountTargetIds=$(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[].MountTargetId[]" --output text | tr '\t' '\n')

        if [[ $mountTargetIds ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo todos os pontos de montagem no sistema de arquivos $tagNameFS"
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
            echo "Não existem pontos de montagem no sistema de arquivos $tagNameFS"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o sistema de arquivos $tagNameFS"
        aws efs delete-file-system --file-system-id $fsId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text
    else
        echo "Não existe o sistema de arquivos $tagNameFS"
    fi
else
    echo "Código não executado"
fi