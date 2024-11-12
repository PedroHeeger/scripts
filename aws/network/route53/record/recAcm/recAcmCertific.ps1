#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD ACM CERTIFICATE-HOSTED ZONE CREATION"

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
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe um certificado para o domínio $domainName"
        $condition = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN do certificado para o domínio $domainName"
            $certificateArn = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].CertificateArn" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o nome do registro CNAME do certificado para o domínio $domainName"
            $resourceRecordName = aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Name" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o valor do registro CNAME do certificado para o domínio $domainName"
            $resourceRecordValue = aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Value" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text
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
                        `"TTL`": 300,
                        `"ResourceRecords`": [
                            {`"Value`": `"${resourceRecordValue}`"}
                        ]
                        }
                    }
                    ]
                }"
        
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text
            }
        } else {Write-Output "Não existe o certificado para o domínio $domainName"}
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD ACM CERTIFICATE-HOSTED ZONE EXCLUSION"

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
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe um certificado para o domínio $domainName"
        $condition = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ARN do certificado para o domínio $domainName"
            $certificateArn = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].CertificateArn" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o nome do registro CNAME do certificado para o domínio $domainName"
            $resourceRecordName = aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Name" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o valor do registro CNAME do certificado para o domínio $domainName"
            $resourceRecordValue = aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Value" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text
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
                            {`"Value`": `"${resourceRecordValue}`"}
                        ]
                        }
                    }
                    ]
                }"
    
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros da hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
    
            } else {Write-Output "Não existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"}   
        } else {Write-Output "Não existe o certificado para o domínio $domainName"}
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}