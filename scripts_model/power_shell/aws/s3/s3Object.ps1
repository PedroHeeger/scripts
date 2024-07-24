#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "OBJECT CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
$objectName = "objTest.jpg"
# $objectName = "objTest1.txt"
$filePath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/power_shell/aws/s3"
$fileName = "objTest.jpg"
# $fileName = "objTest1.txt"
$storageClass = "STANDARD"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket de nome $bucketName"
    if ((aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o objeto de nome $objectName no bucket $bucketName"
        if ((aws s3api list-objects --bucket bucket-test1-ph --query "Contents[?Key=='$objectName'].Key").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o objeto de nome $objectName no bucket $bucketName"   
            aws s3api list-objects --bucket bucket-test1-ph --query "Contents[?Key=='$objectName'].Key" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a URL do objeto de nome $objectName"
            Write-Output "https://$bucketName.s3.amazonaws.com/$objectName" 
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
            aws s3api list-objects --bucket bucket-test1-ph --query "Contents[].Key" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o objeto de nome $objectName no bucket $bucketName"
            aws s3api put-object --bucket $bucketName --key $objectName --body "{$filePath}/{$fileName}" --storage-class $storageClass
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o objeto de nome $objectName no bucket $bucketName"
            aws s3api list-objects --bucket bucket-test1-ph --query "Contents[?Key=='$objectName'].Key" --output text  

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a URL do objeto de nome $objectName"
            Write-Output "https://$bucketName.s3.amazonaws.com/$objectName" 
        }
    } else {Write-Output "Não existe o bucket de nome $bucketName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "OBJECT EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
$objectName = "objTest1.txt"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket de nome $bucketName"
    if ((aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o objeto de nome $objectName no bucket $bucketName"
        if ((aws s3api list-objects --bucket bucket-test1-ph --query "Contents[?Key=='$objectName'].Key").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o objeto de nome $objectName no bucket $bucketName"
            aws s3api delete-object --bucket $bucketName --key $objectName

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
        } else {Write-Output "Não existe o objeto de nome $objectName no bucket $bucketName"}
    } else {Write-Output "Não existe o bucket de nome $bucketName"}    
} else {Write-Host "Código não executado"}