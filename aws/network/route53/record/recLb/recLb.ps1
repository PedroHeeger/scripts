#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD LOAD BALANCER-HOSTED ZONE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$elbName = "albTest1"
# $elbName = "clbTest1"
# $subdomain = "ralb."
$subdomain = "www."
$resourceRecordName = "$subdomain$domainName"
$ttl = "300"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    $condition = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o load balancer $elbName"
        $condition = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o DNS do load balancer $elbName"
            $lbDNS = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].DNSName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o DNS do load balancer $elbName configurado no registro de nome $resourceRecordName"
            $lbDNS = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.'].ResourceRecords[].Value" --output text
        }

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o registro do tipo CNAME $resourceRecordName na hosted zone $hostedZoneName"
        $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                `"Changes`": [
                {
                    `"Action`": `"CREATE`",
                    `"ResourceRecordSet`": {
                    `"Name`": `"${resourceRecordName}`",
                    `"Type`": `"CNAME`",
                    `"TTL`": `"${ttl}`",
                    `"ResourceRecords`": [
                        {`"Value`": `"${lbDNS}`"}
                    ]
                    }
                }
                ]
            }"
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        }
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD LOAD BALANCER-HOSTED ZONE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$elbName = "albTest1"
# $elbName = "clbTest1"
# $subdomain = "ralb."
$subdomain = "www."
$resourceRecordName = "$subdomain$domainName"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    $condition = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o load balancer $elbName"
        $condition = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o DNS do load balancer $elbName"
            $lbDNS = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].DNSName" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o DNS do load balancer $elbName configurado no registro de nome $resourceRecordName"
            $lbDNS = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.'].ResourceRecords[].Value" --output text
        }

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o registro do tipo CNAME $resourceRecordName na hosted zone $hostedZoneName"
        $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
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

        } else {Write-Output "Não existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"}    
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}