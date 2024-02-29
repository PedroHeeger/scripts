#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD LOAD BALANCER-HOSTED ZONE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $hostedZoneName = "hosted-zone-test1.com.br."
# $domainName = "hosted-zone-test1.com.br"
$hostedZoneName = "pedroheeger.dev.br."
$domainName = "pedroheeger.dev.br"
$resourceRecordName = "recordnamelbtest1.pedroheeger.dev.br"
$albName = "albTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    if ((aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o DNS do load balancer $albName"
        $lbDNS = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].DNSName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
        if ((aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                `"Changes`": [
                {
                    `"Action`": `"CREATE`",
                    `"ResourceRecordSet`": {
                    `"Name`": `"${resourceRecordName}`",
                    `"Type`": `"CNAME`",
                    `"TTL`": 300,
                    `"ResourceRecords`": [
                        {`"Value`": `"${lbDNS}`"}
                    ]
                    }
                }
                ]
            }"
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        }
    } else {Write-Output "Não existe a hosted zone de nome $hostedZoneName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD LOAD BALANCER-HOSTED ZONE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $hostedZoneName = "hosted-zone-test1.com.br."
# $domainName = "hosted-zone-test1.com.br"
$hostedZoneName = "pedroheeger.dev.br."
$domainName = "pedroheeger.dev.br"
$resourceRecordName = "recordnamelbtest1.pedroheeger.dev.br"
$albName = "albTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    if ((aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o DNS do load balancer $albName"
        $lbDNS = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].DNSName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
        if ((aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                `"Changes`": [
                {
                    `"Action`": `"DELETE`",
                    `"ResourceRecordSet`": {
                    `"Name`": `"${resourceRecordName}`",
                    `"Type`": `"CNAME`",
                    `"TTL`": 300,
                    `"ResourceRecords`": [
                        {`"Value`": `"${lbDNS}`"}
                    ]
                    }
                }
                ]
            }"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

        } else {Write-Output "Não existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"}    
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}