#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD FAILOVER-HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="pedroheeger.dev.br."
domainName="pedroheeger.dev.br"
resourceRecordName="www.pedroheeger.dev.br"
resourceRecordType="A"
ttl=300
tagNameInstance1="ec2Test1"
tagNameInstance2="ec2Test2"
failoverRecordType1="PRIMARY"   # PRIMARY OR SECONDARY
failoverRecordType2="SECONDARY"   # PRIMARY OR SECONDARY
healthCheckName="healthCheckTest5"
recordId1="Primary"
recordId2="Secondary"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [[ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        # PRIMARY INSTANCE
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
        if [[ $(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].Name" --output text | wc -l) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].SetIdentifier" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstance1"
            instanceIP1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se o IP está vazio, caso esteja extraindo o IP da instância $tagNameInstance1 configurado no registro de nome $resourceRecordName"
            if [ -z "$instanceIP1" ]; then
                instanceIP1=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.' && SetIdentifier=='$recordId1'].ResourceRecords[].Value" --output text)
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID da verificação de integridade de nome $healthCheckName"
            healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch '{
                "Changes": [
                {
                    "Action": "CREATE",
                    "ResourceRecordSet": {
                    "Name": "'"${resourceRecordName}"'",
                    "Type": "'"${resourceRecordType}"'",
                    "TTL": '${ttl}',
                    "ResourceRecords": [
                        {"Value": "'"${instanceIP1}"'"}
                    ],
                    "SetIdentifier": "'"${recordId1}"'",
                    "Failover": "'"${failoverRecordType1}"'",
                    "HealthCheckId": "'"${healthCheckId}"'"
                    }
                }
                ]
            }'

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].SetIdentifier" --output text
        fi


        # SECONDARY INSTANCE
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
        if [[ $(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].Name" --output text | wc -l) -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].SetIdentifier" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstance2"
            instanceIP2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se o IP está vazio, caso esteja extraindo o IP da instância $tagNameInstance2 configurado no registro de nome $resourceRecordName"
            if [ -z "$instanceIP2" ]; then
                instanceIP2=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.' && SetIdentifier=='$recordId2'].ResourceRecords[].Value" --output text)
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
            aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch '{
                "Changes": [
                {
                    "Action": "CREATE",
                    "ResourceRecordSet": {
                    "Name": "'"${resourceRecordName}"'",
                    "Type": "'"${resourceRecordType}"'",
                    "TTL": '${ttl}',
                    "ResourceRecords": [
                        {"Value": "'"${instanceIP2}"'"}
                    ],
                    "SetIdentifier": "'"${recordId2}"'",
                    "Failover": "'"${failoverRecordType2}"'"
                    }
                }
                ]
            }'

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o registro de nome $resourceRecordName com identificador $recordId2 na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].SetIdentifier" --output text
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
echo "RECORD FAILOVER-HOSTED ZONE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="pedroheeger.dev.br."
domainName="pedroheeger.dev.br"
resourceRecordName="www.pedroheeger.dev.br"
resourceRecordType="A"
ttl=300
tagNameInstance1="ec2Test1"
tagNameInstance2="ec2Test2"
failoverRecordType1="PRIMARY"
failoverRecordType2="SECONDARY"
healthCheckName="healthCheckTest5"
recordId1="Primary"
recordId2="Secondary"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        # PRIMARY
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o registro de nome $resourceRecordName com identificador $recordId1 na hosted zone $hostedZoneName"
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId1'].Name" | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstance1"
            instanceIP1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

            echo "Extraindo o ID da verificação de integridade de nome $healthCheckName"
            healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)

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
                    \"Failover\": \"${failoverRecordType1}\",
                    \"HealthCheckId\": \"${healthCheckId}\"
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
        if [ $(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId2'].Name" | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os registros de nome $resourceRecordName na hosted zone $hostedZoneName"
            aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstance2"
            instanceIP2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

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
                    \"Failover\": \"${failoverRecordType2}\"
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
        echo "Não existe a hosted zone $hostedZoneName"
    fi
else
    echo "Código não executado"
fi