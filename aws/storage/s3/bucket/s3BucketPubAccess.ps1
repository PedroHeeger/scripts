#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON S3"
Write-Output "MODIFY BUCKET PUBLIC ACCESS"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$bucketName = "bucket-test1-ph"
$region = "us-east-1"
$blockPublicAcls = "true"          # Impede que qualquer nova ACL pública seja aplicada a objetos no bucket. Qualquer ACL pública existente funciona.
$ignorePublicAcls = "true"         # Faz com que o bucket ignore todas as ACLs públicas existentes, independentemente de quando foram criadas. Mas permite a criação delas.
$blockPublicPolicy = "true"        # Impede que novas políticas públicas (Bucket Policies) sejam aplicadas ao bucket. As existentes continuarão funcionando.
$restrictPublicBuckets = "true"    # Restringe completamente o acesso público ao bucket, tanto por ACLs quanto por Bucket Policies, tanto novas como existentes.

# $blockPublicAcls = "false"
# $ignorePublicAcls = "false"
# $blockPublicPolicy = "true"
# $restrictPublicBuckets = "false"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o bucket $bucketName"
    $condition = aws s3api list-buckets --region $region --query "Buckets[?Name=='$bucketName'].Name" --output text     
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Definindo a query das configurações de bloqueio de acesso público"
        if ($blockPublicAcls -eq "true") {$queryBpa="PublicAccessBlockConfiguration.BlockPublicAcls"} else {$queryBpa="!(PublicAccessBlockConfiguration.BlockPublicAcls)"}
        if ($ignorePublicAcls -eq "true") {$queryIpa="PublicAccessBlockConfiguration.IgnorePublicAcls"} else {$queryIpa="!(PublicAccessBlockConfiguration.IgnorePublicAcls)"}
        if ($blockPublicPolicy -eq "true") {$queryBpp="PublicAccessBlockConfiguration.BlockPublicPolicy"} else {$queryBpp="!(PublicAccessBlockConfiguration.BlockPublicPolicy)"}
        if ($restrictPublicBuckets -eq "true") {$queryRpb="PublicAccessBlockConfiguration.RestrictPublicBuckets"} else {$queryRpb="!(PublicAccessBlockConfiguration.RestrictPublicBuckets)"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se as configurações de bloqueio de acesso público do bucket $bucketName estão conforme definidas nas variáveis"
        $condition = aws s3api get-public-access-block --bucket $bucketName --query "$queryBpa && $queryIpa && $queryBpp && $queryRpb"
        if ($condition -eq "true") {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "As configurações de bloqueio de acesso público do bucket $bucketName estão conforme definição nas variáveis"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration"       
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a configuração de bloqueio de acesso público do bucket $bucketName"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration" 

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Alterando as configurações de bloqueio de acesso público do bucket $bucketName"
            aws s3api put-public-access-block --bucket $bucketName --public-access-block-configuration "BlockPublicAcls=$blockPublicAcls,IgnorePublicAcls=$ignorePublicAcls,BlockPublicPolicy=$blockPublicPolicy,RestrictPublicBuckets=$restrictPublicBuckets"
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a configuração de bloqueio de acesso público do bucket $bucketName"
            aws s3api get-public-access-block --bucket $bucketName --query "PublicAccessBlockConfiguration" 
        }
    } else {Write-Output "Não existe o bucket $bucketName"}
} else {Write-Host "Código não executado"}