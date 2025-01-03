#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "BUCKET CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o bucket $bucketName"
        aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text          
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os buckets na região $region"
        aws s3api list-buckets --region $region --query "Buckets[].Name" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o bucket $bucketName"
        aws s3api create-bucket --bucket $bucketName --region $region

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o bucket $bucketName"
        aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "BUCKET EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os buckets na região $region"
        aws s3api list-buckets --region $region --query "Buckets[].Name" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se há objetos no bucket $bucketName e removendo caso haja"
        $objects = aws s3api list-object-versions --bucket $BucketName --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json | ConvertFrom-Json
        if ($objects.Objects.Count -gt 0) {
            foreach ($object in $objects.Objects) {
                $key = $object.Key
                $versionId = $object.VersionId
                aws s3api delete-object --bucket $BucketName --key $key --version-id $versionId
            }
        }

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o bucket $bucketName"
        aws s3api delete-bucket --bucket $bucketName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os buckets na região $region"
        aws s3api list-buckets --region $region --query "Buckets[].Name" --output text
    } else {Write-Output "Não existe o bucket $bucketName"}
} else {Write-Host "Código não executado"}