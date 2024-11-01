#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "OBJECT OWNERSHIP CHANGE"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
$objectOwnership = "BucketOwnerEnforced"  # O proprietário do bucket detém automaticamente a propriedade de todos os objetos, independentemente de quem os criou. Bloqueia todas as ACLs, e o bucket tem controle total sobre os objetos.
# $objectOwnership = "BucketOwnerPreferred"   # O proprietário do bucket se torna automaticamente o proprietário dos objetos, a menos que o objeto tenha uma ACL específica que defina outro proprietário.
# $objectOwnership = "ObjectWriter"         # O usuário que faz o upload do objeto é o proprietário, mantendo a propriedade dos objetos que eles próprios criaram.

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket $bucketName é o $objectOwnership"
        $condition = aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[?ObjectOwnership=='$objectOwnership'].ObjectOwnership" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já foi configurado o proprietário dos objetos no bucket $bucketName para $objectOwnership"
            aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text   
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o proprietário dos objetos no bucket $bucketName"
            aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Alterando o proprietário dos objetos no bucket $bucketName para $objectOwnership"
            aws s3api put-bucket-ownership-controls --bucket $bucketName --ownership-controls="Rules=[{ObjectOwnership=$objectOwnership}]"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o proprietário dos objetos no bucket $bucketName"
            aws s3api get-bucket-ownership-controls --bucket $bucketName --query "OwnershipControls.Rules[].ObjectOwnership" --output text 
        }
    } else {Write-Output "Não existe o bucket $bucketName"}
} else {Write-Host "Código não executado"}