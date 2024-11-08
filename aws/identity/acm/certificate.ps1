#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ACM"
Write-Output "CERTIFICATE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$domainName = "hosted-zone-test1.com.br"
# $domainName = "pedroheeger.dev.br"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um certificado para o domínio $domainName"
    $condition = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe um certificado para o domínio $domainName"
        aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando os nomes de domínio de todos certificados existentes"
        aws acm list-certificates --query "CertificateSummaryList[].DomainName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um certificado para o domínio $domainName"
        aws acm request-certificate --domain-name $domainName --validation-method DNS

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando um certificado para o domínio $domainName"
        aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ACM"
Write-Output "CERTIFICATE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$domainName = "hosted-zone-test1.com.br"
# $domainName = "pedroheeger.dev.br"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um certificado para o domínio $domainName"
    $condition = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando os nomes de domínio de todos certificados existentes"
        aws acm list-certificates --query "CertificateSummaryList[].DomainName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN do certificado para o domínio $domainName"
        $certificateArn = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].CertificateArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o certificado para o domínio $domainName"
        aws acm delete-certificate --certificate-arn $certificateArn
        Start-Sleep 5

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando os nomes de domínio de todos certificados existentes"
        aws acm list-certificates --query "CertificateSummaryList[].DomainName" --output text
    } else {Write-Output "Não existe o certificado para o domínio $domainName"}
} else {Write-Host "Código não executado"}