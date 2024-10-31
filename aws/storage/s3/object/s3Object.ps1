#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "OBJECT CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
$objectName = "objTest.jpg"
$filePath = "G:/Meu Drive/4_PROJ/scripts/aws/storage/s3/object"
$fileName = "objTest.jpg"
$storageClass = "STANDARD"
$contentType = "image/jpg"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o objeto $objectName no bucket $bucketName"
        $condition = aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text
        if (($condition).Count -gt 0 -and $condition -ne "None") {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o objeto $objectName no bucket $bucketName"   
            aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a URL do objeto $objectName"
            Write-Output "https://$bucketName.s3.amazonaws.com/$objectName" 
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o objeto $objectName no bucket $bucketName"
            aws s3api put-object --bucket $bucketName --key $objectName --body "$filePath/$fileName" --storage-class $storageClass --content-type $contentType
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o objeto $objectName no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text  

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a URL do objeto $objectName"
            Write-Output "https://$bucketName.s3.amazonaws.com/$objectName" 
        }
    } else {Write-Output "Não existe o bucket $bucketName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "OBJECT EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
$objectName = "objTest.jpg"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o objeto $objectName no bucket $bucketName"
        $condition = aws s3api list-objects --bucket $bucketName --query "Contents[?Key=='$objectName'].Key" --output text
        # $condition = aws s3api list-objects --bucket bucket-test1-ph --query "Contents[?Key=='objTest.jpg'].Key" --output text
        if (($condition).Count -gt 0 -and $condition -ne "None") {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o objeto $objectName no bucket $bucketName"
            aws s3api delete-object --bucket $bucketName --key $objectName

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os objetos no bucket $bucketName"
            aws s3api list-objects --bucket $bucketName --query "Contents[].Key" --output text
        } else {Write-Output "Não existe o objeto $objectName no bucket $bucketName"}
    } else {Write-Output "Não existe o bucket $bucketName"}    
} else {Write-Host "Código não executado"}