#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD LOAD BALANCER-HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
elbName="albTest1"
# elbName="clbTest1"
# subdomain="ralb."
subdomain="www."
resourceRecordName="${subdomain}${domainName}"
ttl="300"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    condition=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o load balancer $elbName"
        condition=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o DNS do load balancer $elbName"
            lbDNS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].DNSName" --output text)
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o DNS do load balancer $elbName configurado no registro de nome $resourceRecordName"
            lbDNS=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.'].ResourceRecords[].Value" --output text)
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
        condition=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                \"Changes\": [
                    {
                        \"Action\": \"CREATE\",
                        \"ResourceRecordSet\": {
                            \"Name\": \"${resourceRecordName}\",
                            \"Type\": \"CNAME\",
                            \"TTL\": \"${ttl}\",
                            \"ResourceRecords\": [
                                {\"Value\": \"${lbDNS}\"}
                            ]
                        }
                    }
                ]
            }"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        fi
    else
        echo "Não existe a hosted zone $hostedZoneName"
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
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
elbName="albTest1"
# elbName="clbTest1"
subdomain="ralb."
# subdomain="www."
resourceRecordName="${subdomain}${domainName}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    condition=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o load balancer $elbName"
        condition=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o DNS do load balancer $elbName"
            lbDNS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].DNSName" --output text)
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o DNS do load balancer $elbName configurado no registro de nome $resourceRecordName"
            lbDNS=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.'].ResourceRecords[].Value" --output text)
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
        condition=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
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
            echo "Não existe o registro CNAME $resourceRecordName na hosted zone $hostedZoneName"
        fi    
    else
        echo "Não existe a hosted zone $hostedZoneName"
    fi
else
    echo "Código não executado"
fi