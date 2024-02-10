#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# hostedZoneName="hosted-zone-test1.com.br."
# domainName="hosted-zone-test1.com.br"
hostedZoneName="pedroheeger.dev.br."
domainName="pedroheeger.dev.br"
hostedZoneReference="hostedZoneReferenceTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone de nome $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a hosted zone de nome $hostedZoneName"
        aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a hosted zone de nome $hostedZoneName"
        aws route53 create-hosted-zone --name $domainName --caller-reference $hostedZoneReference --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a hosted zone de nome $hostedZoneName"
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
# hostedZoneName="hosted-zone-test1.com.br."
hostedZoneName="pedroheeger.dev.br."

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone de nome $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone de nome $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a hosted zone de nome $hostedZoneName"
        aws route53 delete-hosted-zone --id $hostedZoneId

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as hosted zones existentes"
        aws route53 list-hosted-zones --query "HostedZones[].Name" --output text
    else
        echo "Não existe a hosted zone de nome $hostedZoneName"
    fi
else
    echo "Código não executado"
fi