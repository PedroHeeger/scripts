#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD SIMPLE ROUTING POLICY-HOSTED ZONE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$tagNameInstance = "ec2Test1"
$subdomain = "rsrp."
# $subdomain = "www."
$resourceRecordName = "$subdomain$domainName"
$resourceRecordType = "A"
$ttl = 300

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName e a instância $tagNameInstance"
    $condition = (aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text).Count -gt 0 && (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text).Count -gt 0
    if (($condition)) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o IP público da instância $tagNameInstance"
        $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
        $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                `"Changes`": [
                {
                    `"Action`": `"CREATE`",
                    `"ResourceRecordSet`": {
                    `"Name`": `"${resourceRecordName}`",
                    `"Type`": `"${resourceRecordType}`",
                    `"TTL`": ${ttl},
                    `"ResourceRecords`": [
                        {`"Value`": `"${instanceIP}`"}
                    ]
                    }
                }
                ]
            }"
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        }
    } else {Write-Output "Não existe a hosted zone $hostedZoneName ou a instância $tagNameInstance"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD SIMPLE ROUTING POLICY-HOSTED ZONE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$tagNameInstance = "ec2Test1"
$subdomain = "rsrp."
# $subdomain = "www."
$resourceRecordName = "$subdomain$domainName"
$resourceRecordType = "A"
$ttl = 300

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName e a instância $tagNameInstance"
    $condition = (aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text).Count -gt 0 && (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text).Count -gt 0
    if (($condition)) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o IP público da instância $tagNameInstance"
        $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
        $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                `"Changes`": [
                {
                    `"Action`": `"DELETE`",
                    `"ResourceRecordSet`": {
                    `"Name`": `"${resourceRecordName}`",
                    `"Type`": `"${resourceRecordType}`",
                    `"TTL`": ${ttl},
                    `"ResourceRecords`": [
                        {`"Value`": `"${instanceIP}`"}
                    ]
                    }
                }
                ]
            }"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
        } else {Write-Output "Não existe o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"}    
    } else {Write-Output "Não existe a hosted zone $hostedZoneName ou a instância $tagNameInstance"}
} else {Write-Host "Código não executado"}