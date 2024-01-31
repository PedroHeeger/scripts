#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD LOAD BALANCER-HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="hosted-zone-test1.com.br."
domainName="hosted-zone-test1.com.br"
resourceRecordName="recordNameLbTest1"
albName="albTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o DNS do load balancer $albName"
        lbDNS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].DNSName" --output text)

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
                                {\"Value\": \"${lbDNS}\"}
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
echo "RECORD LOAD BALANCER-HOSTED ZONE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="hosted-zone-test1.com.br."
domainName="hosted-zone-test1.com.br"
resourceRecordName="recordNameLbTest1"
albName="albTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o DNS do load balancer $albName"
        lbDNS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].DNSName" --output text)

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
                                {\"Value\": \"${lbDNS}\"}
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