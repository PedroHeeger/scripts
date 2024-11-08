#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "HOSTED ZONE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$hostedZoneReference = "hostedZoneReferenceTest" + (Get-Date -Format "yyyyMMddHHmmss")
$domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
# $domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$description = "Hosted Zone Test 1"
$privateZone = $false

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    $condition = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a hosted zone $hostedZoneName"
        aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a hosted zone $hostedZoneName"
        aws route53 create-hosted-zone --name $domainName --caller-reference $hostedZoneReference --hosted-zone-config "Comment=$description,PrivateZone=$privateZone" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a hosted zone $hostedZoneName"
        aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "HOSTED ZONE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
# $domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    $condition = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a hosted zone $hostedZoneName"
        aws route53 delete-hosted-zone --id $hostedZoneId

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}