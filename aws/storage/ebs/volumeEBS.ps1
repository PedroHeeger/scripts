#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EBS"
Write-Output "VOLUME CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$size = 10
$az = "us-east-1a"
$volumeType = "gp2"
$tagNameVolume = "volumeEBSTest1"
$awsAccountId = "001727357081"
$tagNameSnapshot = "snapshotEBSTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o volume do EBS $tagNameVolume"
    $condition = aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o volume do EBS $tagNameVolume"
        aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o volume do EBS $tagNameVolume"
        aws ec2 create-volume --size $size --availability-zone $az --volume-type $volumeType --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$tagNameVolume}]" --encrypted --no-cli-pager

        # Descomente as linhas abaixo se precisar criar um volume a partir de um snapshot e comente a linha de criação acima
        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Verificando se existe o snapshot $tagNameSnapshot"
        # $condition = aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text
        # if (($condition).Count -gt 0) {
            # Write-Output "-----//-----//-----//-----//-----//-----//-----"
            # Write-Output "Extraindo o ID do snapshot do EBS $tagNameSnapshot"
            # $snapshotId = aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[?Tags[?Key=='Name' && Value=='$tagNameSnapshot']].SnapshotId" --output text

            # Write-Output "-----//-----//-----//-----//-----//-----//-----"
            # Write-Output "Criando o volume do EBS $tagNameVolume a partir do snapshot $tagNameSnapshot"
            # aws ec2 create-volume --snapshot-id $snapshotId --size $size --availability-zone $az --volume-type $volumeType --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$tagNameVolume}]" --encrypted --no-cli-pager
        # } else {Write-Output "Não existe o snapshot do EBS $tagNameSnapshot"}         

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando apenas o volume do EBS $tagNameVolume"
        aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EBS"
Write-Output "VOLUME EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameVolume = "volumeEBSTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o volume do EBS $tagNameVolume"
    $condition = aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ID do volume do EBS $tagNameVolume"
        $volumeId = aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe instâncias anexadas ao volume do EBS $tagNameVolume"
        if ((aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].Attachments[]").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Host "Desanexando o volume do EBS $tagNameVolume da instância"
            aws ec2 detach-volume --volume-id $volumeId
        } else {Write-Host "Não existe instâncias anexadas ao volume do EBS $tagNameVolume"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Host "Aguardando o volume do EBS $tagNameVolume ficar disponivel"
        $state = ""
        while ($state -ne "available") {Start-Sleep -Seconds 5; $state = (aws ec2 describe-volumes --volume-ids $volumeId --query "Volumes[0].State" --output text); Write-Output "Current state: $state"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o volume do EBS $tagNameVolume"
        aws ec2 delete-volume --volume-id $volumeId

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os volumes do EBS criado"
        aws ec2 describe-volumes --query "Volumes[].VolumeId" --output text
    } else {Write-Output "Não existe o volume do EBS $tagNameVolume"}
} else {Write-Host "Código não executado"}