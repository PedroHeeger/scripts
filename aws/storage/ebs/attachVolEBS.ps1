#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EBS"
Write-Output "ATTACH VOLUME"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameVolume = "volumeEBSTest1"
# $deviceName = "/dev/sdf"
$deviceName = "/dev/xvdf"
$tagNameInstance = "ec2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o volume do EBS $tagNameVolume e a instância ativa $tagNameInstance"
    $condition = (aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da instância $tagNameInstance"
        $instanceId1 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se o volume do EBS $tagNameVolume está anexado a instância $tagNameInstance"
        if ((aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já está anexado o volume do EBS $tagNameVolume a instância $tagNameInstance"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o ID de todas as instâncias anexadas ao volume do EBS $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[].InstanceId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ID do volume do EBS $tagNameVolume"
            $volumeId = aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Anexado o volume do EBS $tagNameVolume a instância $tagNameInstance"
            aws ec2 attach-volume --volume-id $volumeId --instance-id $instanceId1 --device $deviceName

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando apenas a instância $tagNameInstance anexada ao volume do EBS $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId" --output text
        }
    } else {Write-Host "Não existe o volume do EBS $tagNameVolume ou a instância ativa $tagNameInstance"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EBS"
Write-Output "DETACH VOLUME"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameVolume = "volumeEBSTest1"
$tagNameInstance = "ec2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o volume do EBS $tagNameVolume e a instância ativa $tagNameInstance"
    $condition = (aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text).Count -gt 0
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da instância $tagNameInstance"
        $instanceId1 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se o volume do EBS $tagNameVolume está anexado a instância $tagNameInstance"
        if ((aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume'] && Attachments[?InstanceId=='$instanceId1']].Attachments[].InstanceId").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o ID de todas as instâncias anexadas ao volume do EBS $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[].InstanceId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ID do volume do EBS $tagNameVolume"
            $volumeId = aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Host "Desanexando o volume do EBS $tagNameVolume da instância $tagNameInstance"
            aws ec2 detach-volume --volume-id $volumeId

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Host "Aguardando o volume do EBS $tagNameVolume ficar disponivel"
            $state = ""
            while ($state -ne "available") {Start-Sleep -Seconds 5; $state = (aws ec2 describe-volumes --volume-ids $volumeId --query "Volumes[0].State" --output text); Write-Output "Current state: $state"}

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o ID de todas as instâncias anexadas ao volume do EBS $tagNameVolume"
            aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[].InstanceId" --output text
        } else {Write-Output "Não está anexado o volume do EBS $tagNameVolume a instância $tagNameInstance"}
    } else {Write-Host "Não existe o volume do EBS $tagNameVolume ou a instância ativa $tagNameInstance"}
} else {Write-Host "Código não executado"}