#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EBS"
Write-Output "SNAPSHOT CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$awsAccountId = "001727357081"
$tagNameVolume = "volumeEBSTest1"
$snapshotDescription = "Snapshot Description Test 1"
$tagNameSnapshot = "snapshotEBSTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o volume do EBS $tagNameVolume"
    $condition = aws ec2 describe-volumes --query "Volumes[].Tags[?Key=='Name' && Value=='$tagNameVolume'].Value[]" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o snapshot $tagNameSnapshot"
        $condition = aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o snapshot $tagNameSnapshot"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os snapshots do EBS criado da conta especificada"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].SnapshotId" --output text
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ID do volume do EBS $tagNameVolume"
            $volumeId = aws ec2 describe-volumes --query "Volumes[?Tags[?Key=='Name' && Value=='$tagNameVolume']].VolumeId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o snapshot $tagNameSnapshot a partir do volume do EBS $tagNameVolume"
            aws ec2 create-snapshot --volume-id $volumeId --description "$snapshotDescription" --tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=$tagNameSnapshot}]" --no-cli-pager
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Host "Aguardando o snapshot $tagNameVolume ser concluído"
            $state = ""
            while ($state -ne "completed") {Start-Sleep -Seconds 10; $state = (aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[?Tags[?Key=='Name' && Value=='$tagNameSnapshot']].State" --output text); Write-Output "Current state: $state"}

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando apenas o snapshot do EBS $tagNameSnapshot"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text
        }
    } else {Write-Output "Não existe o volume do EBS $tagNameVolume"}        
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EBS"
Write-Output "SNAPSHOT EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
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
        Write-Output "Verificando se existe o snapshot $tagNameSnapshot"
        $condition = aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].Tags[?Key=='Name' && Value=='$tagNameSnapshot'].Value[]" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os snapshots do EBS criado da conta especificada"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].SnapshotId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ID do snapshot do EBS $tagNameSnapshot"
            $snapshotId = aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[?Tags[?Key=='Name' && Value=='$tagNameSnapshot']].SnapshotId" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o snapshot do EBS $tagNameSnapshot"
            aws ec2 delete-snapshot --snapshot-id $snapshotId

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os snapshots do EBS criado da conta especificada"
            aws ec2 describe-snapshots --owner-ids $awsAccountId --query "Snapshots[].SnapshotId" --output text
        } else {Write-Output "Não existe o snapshot do EBS $tagNameSnapshot"}
    } else {Write-Output "Não existe o volume do EBS $tagNameVolume"}   
} else {Write-Host "Código não executado"}