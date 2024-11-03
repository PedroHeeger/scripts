#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EFS"
Write-Output "FILE SYSTEM CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$efsToken = "fsTokenEFSTest1"
$tagNameFS = "fsEFSTest1"
$performanceMode = "generalPurpose"   # Modo padrão adequado para a maioria das cargas de trabalho, oferecendo latência moderada e desempenho equilibrado.
# $performanceMode = "maxIO"            # Otimizado para cargas de trabalho de alta taxa de I/O, oferecendo maior throughput e latência mais consistente para aplicações que demandam alto desempenho.
$throughputMode = "bursting"          # Modo padrão que permite picos de throughput acima do nível base usando créditos acumulados, adequado para cargas de trabalho com variação no uso.
# $throughputMode = "provisioned"       # Permite configurar um nível fixo de throughput, garantindo capacidade constante para cargas de trabalho com requisitos de I/O consistentes.
$aZ = "us-east-1a"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o sistema de arquivos $tagNameFS"
    $condition = aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o sistema de arquivos $tagNameFS"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o sistema de arquivos $tagNameFS"
        aws efs create-file-system --creation-token $efsToken --performance-mode $performanceMode --throughput-mode $throughputMode --tags "Key=Name,Value=$tagNameFS" --no-cli-pager

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Criando o sistema de arquivos $tagNameFS em uma AZ determinada"
        # aws efs create-file-system --creation-token $efsToken --performance-mode $performanceMode --throughput-mode $throughputMode --availability-zone-name $aZ --tags "Key=Name,Value=$tagNameFS" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando apenas o sistema de arquivos $tagNameFS"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EFS"
Write-Output "FILE SYSTEM EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameFS = "fsEFSTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o sistema de arquivos $tagNameFS"
    $condition = aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name' && Value=='$tagNameFS'].Value[]" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ID do sistema de arquivos $tagNameFS"
        $fsId = aws efs describe-file-systems --query "FileSystems[?Tags[?Key=='Name' && Value=='$tagNameFS']].FileSystemId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existem pontos de montagem no sistema de arquivos $tagNameFS"
        $mountTargetIds = (aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[].MountTargetId[]" --output text) -split '\s+'

        if ($mountTargetIds) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo todos os pontos de montagem no sistema de arquivos $tagNameFS"
            foreach ($mountTargetId in $mountTargetIds) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Removendo ponto de montagem $mountTargetId"
                aws efs delete-mount-target --mount-target-id $mountTargetId

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Aguardando a remoção do ponto de montagem $mountTargetId"
                $state = "deleting"
                while ($state -eq "creating" -or $state -eq "available" -or $state -eq "deleting") {Start-Sleep -Seconds 5; $state = (aws efs describe-mount-targets --file-system-id $fsId --query "MountTargets[?MountTargetId=='$mountTargetId'].LifeCycleState[]" --output text); Write-Output "Current state: $state"}
            }
        } else {Write-Host "Não existem pontos de montagem no sistema de arquivos $tagNameFS"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o sistema de arquivos $tagNameFS"
        aws efs delete-file-system --file-system-id $fsId

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os sistemas de arquivos"
        aws efs describe-file-systems --query "FileSystems[].Tags[?Key=='Name'].Value" --output text
    } else {Write-Output "Não existe o sistema de arquivos $tagNameFS"}
} else {Write-Host "Código não executado"}