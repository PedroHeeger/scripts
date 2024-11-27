#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD SIMPLE ROUTING POLICY-HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
tagNameInstance="ec2Test1"
subdomain="rsrp."
# subdomain="www."
resourceRecordName="${subdomain}${domainName}"
resourceRecordType="A"
ttl=300

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName e a instância $tagNameInstance"
    condition=$( (aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 0 && (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text | cut -d'/' -f3)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o IP público da instância $tagNameInstance"
        instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
        condition=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch '{
                "Changes": [
                    {
                        "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'"${resourceRecordName}"'.",
                            "Type": "'"${resourceRecordType}"'",
                            "TTL": "'"${ttl}"'",
                            "ResourceRecords": [
                                {
                                    "Value": "'"${instanceIP}"'"
                                }
                            ]
                        }
                    }
                ]
            }'

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
        fi
    else
        echo "Não existe a hosted zone $hostedZoneName ou a instância $tagNameInstance"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD SIMPLE ROUTING POLICY-HOSTED ZONE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
tagNameInstance="ec2Test1"
subdomain="rsrp."
# subdomain="www."
resourceRecordName="${subdomain}${domainName}"
resourceRecordType="A"
ttl=300

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName e a instância $tagNameInstance"
    condition=$( (aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 0 && (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text | wc -l) -gt 0 )
    if [[ "$condition" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text | cut -d'/' -f3)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o IP público da instância $tagNameInstance"
        instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
        condition=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch '{
                "Changes": [
                    {
                        "Action": "DELETE",
                        "ResourceRecordSet": {
                            "Name": "'"${resourceRecordName}"'.",
                            "Type": "'"${resourceRecordType}"'",
                            "TTL": "'"${ttl}"'",
                            "ResourceRecords": [
                                {
                                    "Value": "'"${instanceIP}"'"
                                }
                            ]
                        }
                    }
                ]
            }'

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros da hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

        else
            echo "Não existe o registro do tipo A $resourceRecordName na hosted zone $hostedZoneName"
        fi
    else
        echo "Não existe a hosted zone $hostedZoneName ou a instância $tagNameInstance"
    fi
else
    echo "Código não executado"
fi