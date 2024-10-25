#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EFS"
echo "MOUNT TARGET CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameFS="fsEFSTest1"
sgName="default"
aZ="us-east-1a"
# aZ="us-east-1b"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" = "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o sistema de arquivos de tag de nome $tagNameFS"
    if [ $(aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID do sistema de arquivos de tag de nome $tagNameFS"
        fsId=$(aws efs describe-file-systems --query "FileSystems[?Tags[?Key=='Name' && Value=='$tagNameFS']].FileSystemId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id dos elementos de rede"
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)
        subnetId=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ'].SubnetId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
        if [ $(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?AvailabilityZoneName=='$aZ'].MountTargetId[]" --output text | wc -l) -gt 0 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe um ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
            aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?AvailabilityZoneName=='$aZ'].MountTargetId[]" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os pontos de montagem existentes no sistema de arquivo de tag de nome $tagNameFS"
            aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[].MountTargetId[]" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando um ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
            aws efs create-mount-target --file-system-id $fsId --subnet-id $subnetId --security-groups $sgId --no-cli-pager

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Aguardando o ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ ficar disponível"
            state=""
            while [ "$state" != "available" ]; do
                sleep 8
                state=$(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?AvailabilityZoneName=='$aZ'].LifeCycleState[]" --output text)
                echo "Current state: $state"
            done

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando apenas o ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
            aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?AvailabilityZoneName=='$aZ'].MountTargetId[]" --output text
        fi
    else
        echo "Não existe o sistema de arquivos de tag de nome $tagNameFS"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EFS"
echo "MOUNT TARGET EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameFS="fsEFSTest1"
sgName="default"
aZ="us-east-1a"
# aZ="us-east-1b"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" = "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o sistema de arquivos de tag de nome $tagNameFS"
    if [ $(aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ID do sistema de arquivos de tag de nome $tagNameFS"
        fsId=$(aws efs describe-file-systems --query "FileSystems[?Tags[?Key=='Name' && Value=='$tagNameFS']].FileSystemId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id dos elementos de rede"
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)
        subnetId=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ'].SubnetId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
        if [ $(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?AvailabilityZoneName=='$aZ'].MountTargetId[]" --output text | wc -l) -gt 0 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os pontos de montagem existentes no sistema de arquivo de tag de nome $tagNameFS"
            aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[].MountTargetId[]" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID do ponto de montagem do sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
            mountTargetId=$(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?AvailabilityZoneName=='$aZ'].MountTargetId[]" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o ponto de montagem do sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
            aws efs delete-mount-target --mount-target-id $mountTargetId

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Aguardando o ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ ser deletado"
            state="deleting"
            while [ "$state" == "creating" ] || [ "$state" == "available" ] || [ "$state" == "deleting" ]; do
                sleep 5
                state=$(aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?AvailabilityZoneName=='$aZ'].LifeCycleState[]" --output text)
                echo "Current state: $state"
            done

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os pontos de montagem existentes no sistema de arquivo de tag de nome $tagNameFS"
            aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[].MountTargetId[]" --output text
        else
            echo "Não existe nenhum ponto de montagem no sistema de arquivos de tag de nome $tagNameFS na AZ $aZ"
        fi
    else
        echo "Não existe o sistema de arquivos de tag de nome $tagNameFS"
    fi
else
    echo "Código não executado"
fi