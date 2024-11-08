#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneReference="hostedZoneReferenceTest$(date +"%Y%m%d%H%M%S")"
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
description="Hosted Zone Test 1"
privateZone=false

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    condition=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a hosted zone $hostedZoneName"
        aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a hosted zone $hostedZoneName"
        aws route53 create-hosted-zone --name $domainName --caller-reference $hostedZoneReference --hosted-zone-config "Comment=$description,PrivateZone=$privateZone" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a hosted zone $hostedZoneName"
        aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "HOSTED ZONE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    condition=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a hosted zone $hostedZoneName"
        aws route53 delete-hosted-zone --id $hostedZoneId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text
    else
        echo "Não existe a hosted zone $hostedZoneName"
    fi
else
    echo "Código não executado"
fi