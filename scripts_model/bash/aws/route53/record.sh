#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD-HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="hosted-zone-test1.com.br."
domainName="hosted-zone-test1.com.br"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um certificado para o domínio $domainName"
        if [ $(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ARN do certificado para o domínio $domainName"
            certificateArn=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].CertificateArn" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o nome do recurso de registro do certificado para o domínio $domainName"
            resourceRecordName=$(aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Name" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o valor do recurso de registro do certificado para o domínio $domainName"
            resourceRecordValue=$(aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Value" --output text)
        else
            echo "Não existe o certificado para o domínio $domainName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                \"Changes\": [
                {
                    \"Action\": \"CREATE\",
                    \"ResourceRecordSet\": {
                    \"Name\": \"${resourceRecordName}\",
                    \"Type\": \"CNAME\",
                    \"TTL\": 300,
                    \"ResourceRecords\": [
                        {\"Value\": \"${resourceRecordValue}\"}
                    ]
                    }
                }
                ]
            }"
    
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text
        fi
    else
        echo "Não existe a hosted zone de nome $hostedZoneName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD-HOSTED ZONE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="hosted-zone-test1.com.br."
domainName="hosted-zone-test1.com.br"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um certificado para o domínio $domainName"
        if [ $(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ARN do certificado para o domínio $domainName"
            certificateArn=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].CertificateArn" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o nome do recurso de registro do certificado para o domínio $domainName"
            resourceRecordName=$(aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Name" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o valor do recurso de registro do certificado para o domínio $domainName"
            resourceRecordValue=$(aws acm describe-certificate --certificate-arn $certificateArn --query "Certificate.DomainValidationOptions[?DomainName=='$domainName'].ResourceRecord.Value" --output text)
        else
            echo "Não existe o certificado para o domínio $domainName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName'].Name" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                \"Changes\": [
                {
                    \"Action\": \"DELETE\",
                    \"ResourceRecordSet\": {
                    \"Name\": \"${resourceRecordName}\",
                    \"Type\": \"CNAME\",
                    \"TTL\": 300,
                    \"ResourceRecords\": [
                        {\"Value\": \"${resourceRecordValue}\"}
                    ]
                    }
                }
                ]
            }"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

        else
            echo "Não existe o registro de nome $resourceRecordName na hosted zone $hostedZoneName"
        fi    
    else
        echo "Não existe a hosted zone $hostedZoneName"
    fi
else
    echo "Código não executado"
fi