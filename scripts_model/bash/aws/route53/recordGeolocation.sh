#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD GEOLOCATION-HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# hostedZoneName="hosted-zone-test1.com.br."
# domainName="hosted-zone-test1.com.br"
hostedZoneName="pedroheeger.dev.br."
domainName="pedroheeger.dev.br"
resourceRecordName="www.pedroheeger.dev.br"
resourceRecordType="A"
ttl=300
tagNameInstanceA="ec2Test1"
tagNameInstanceB="ec2Test2"
recordId1="US-NorthVirginia"
recordId2="Europe-Paris"
countryCode1="US"
# countryCode1="BR"
countryCode2="FR"
subdivisionCode1="VA"
region1="us-east-1"
region2="eu-west-3"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        # PRIMARY INSTANCE
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].Name" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].SetIdentifier" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstanceA"
            instanceIP1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstanceA" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region1 --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                \"Changes\": [
                {
                    \"Action\": \"CREATE\",
                    \"ResourceRecordSet\": {
                    \"Name\": \"${resourceRecordName}\",
                    \"Type\": \"${resourceRecordType}\",
                    \"TTL\": ${ttl},
                    \"ResourceRecords\": [
                        {\"Value\": \"${instanceIP1}\"}
                    ],
                    \"SetIdentifier\": \"${recordId1}\",
                    \"GeoLocation\": {
                        \"CountryCode\": \"${countryCode1}\",
                        \"SubdivisionCode\": \"${subdivisionCode1}\"
                    }
                    }
                }
                ]
            }"
    
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].SetIdentifier" --output text

        # SECONDARY INSTANCE
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].Name" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].SetIdentifier" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstanceB"
            instanceIP2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstanceB" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region2 --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                \"Changes\": [
                {
                    \"Action\": \"CREATE\",
                    \"ResourceRecordSet\": {
                    \"Name\": \"${resourceRecordName}\",
                    \"Type\": \"${resourceRecordType}\",
                    \"TTL\": ${ttl},
                    \"ResourceRecords\": [
                        {\"Value\": \"${instanceIP2}\"}
                    ],
                    \"SetIdentifier\": \"${recordId2}\",
                    \"GeoLocation\": {
                        \"CountryCode\": \"${countryCode2}\"
                    }
                    }
                }
                ]
            }"
    
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].SetIdentifier" --output text
    else
        echo "Não existe a hosted zone de nome $hostedZoneName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD GEOLOCATION-HOSTED ZONE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# hostedZoneName="hosted-zone-test1.com.br."
# domainName="hosted-zone-test1.com.br"
hostedZoneName="pedroheeger.dev.br."
domainName="pedroheeger.dev.br"
resourceRecordName="www.pedroheeger.dev.br"
resourceRecordType="A"
ttl=300
tagNameInstanceA="ec2Test1"
tagNameInstanceB="ec2Test2"
recordId1="US-NorthVirginia"
recordId2="Europe-Paris"
countryCode1="US"
# countryCode1="BR"
countryCode2="FR"
subdivisionCode1="VA"
region1="us-east-1"
region2="eu-west-3"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" = "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        # PRIMARY
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].Name" --output text | wc -l) -gt 0 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstanceA"
            instanceIP1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstanceA" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region1 --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                \"Changes\": [
                {
                    \"Action\": \"DELETE\",
                    \"ResourceRecordSet\": {
                    \"Name\": \"${resourceRecordName}\",
                    \"Type\": \"${resourceRecordType}\",
                    \"TTL\": ${ttl},
                    \"ResourceRecords\": [
                        {\"Value\": \"${instanceIP1}\"}
                    ],
                    \"SetIdentifier\": \"${recordId1}\",
                    \"GeoLocation\": {
                        \"CountryCode\": \"${countryCode1}\",
                        \"SubdivisionCode\": \"${subdivisionCode1}\"
                    }
                    }
                }
                ]
            }"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text
        else
            echo "Não existe o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
        fi

        # SECONDARY
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].Name" --output text | wc -l) -gt 0 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstanceB"
            instanceIP2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstanceB" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region2 --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                \"Changes\": [
                {
                    \"Action\": \"DELETE\",
                    \"ResourceRecordSet\": {
                    \"Name\": \"${resourceRecordName}\",
                    \"Type\": \"${resourceRecordType}\",
                    \"TTL\": ${ttl},
                    \"ResourceRecords\": [
                        {\"Value\": \"${instanceIP2}\"}
                    ],
                    \"SetIdentifier\": \"${recordId2}\",
                    \"GeoLocation\": {
                        \"CountryCode\": \"${countryCode2}\"
                    }
                    }
                }
                ]
            }"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text
        else
            echo "Não existe o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
        fi
    else
        echo "Não existe a hosted zone de nome $hostedZoneName"
    fi
else
    echo "Código não executado"
fi