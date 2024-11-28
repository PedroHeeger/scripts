#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD ROUTING POLICIES-HOSTED ZONE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
domainName="pedroheeger.dev.br"
hostedZoneName="$domainName."
subdomain="www."
resourceRecordType="A"
ttl=300

# Simple Routing Policy (SRP)
# routingPolicy="SRP"
# subdomain="rsrp."
# tagNameInstance1="ec2Test1"

# Failover Policy (FOP)
# routingPolicy="FOP"
# subdomain="rfop."
# tagNameInstance1="ec2Test1"
# tagNameInstance2="ec2Test2"
# failoverRecordType1="PRIMARY"   # PRIMARY OR SECONDARY
# failoverRecordType2="SECONDARY"   # PRIMARY OR SECONDARY
# healthCheckName="healthCheckTest1"
# recordId1="Primary"
# recordId2="Secondary"
# region1="us-east-1"
# region2="sa-east-1"

# Geolocation Policy (GLP)
routingPolicy="GLP"
# subdomain="rglp."
tagNameInstance1="ec2Test1"
tagNameInstance2="ec2Test2"
recordId1="US-NorthVirginia"
recordId2="Brasil-SP"
countryCode1="US"
subdivisionCode1="VA"
countryCode2="BR"
region1="us-east-1"
region2="sa-east-1"

resourceRecordName="$subdomain$domainName"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "$resposta" == "y" || "$resposta" == "Y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

    if [ -n "$hostedZoneId" ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"

        function CreateRecordSRP() { hostedZoneId=$1 hostedZoneName=$2 resourceRecordName=$3 resourceRecordType=$4 ttl=$5 tagNameInstance=$6
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o registro $resourceRecordName na hosted zone $hostedZoneName"
            condition=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text)
            if [[ -n "$condition" ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[].Name" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o IP da instância $tagNameInstance"
                instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Criando o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{
                    \"Changes\": [
                        {
                            \"Action\": \"CREATE\",
                            \"ResourceRecordSet\": {
                                \"Name\": \"${resourceRecordName}\",
                                \"Type\": \"${resourceRecordType}\",
                                \"TTL\": ${ttl},
                                \"ResourceRecords\": [
                                    {\"Value\": \"${instanceIP}\"}
                                ]
                            }
                        }
                    ]
                }"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
            fi
        }


        function CreateRecordFOP() {hostedZoneId=$1 hostedZoneName=$2 resourceRecordName=$3 recordId=$4 resourceRecordType=$5 ttl=$6 failoverRecordType=$7 tagNameInstance=$8
            healthCheckName=$9 region=${10}

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            condition=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].Name" --output text)
            if [[ -n "$condition" ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o IP da instância $tagNameInstance"
                instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text)

                if [[ -z "$healthCheckName" ]]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{
                        \"Changes\": [
                            {
                                \"Action\": \"CREATE\",
                                \"ResourceRecordSet\": {
                                    \"Name\": \"${resourceRecordName}\",
                                    \"Type\": \"${resourceRecordType}\",
                                    \"TTL\": ${ttl},
                                    \"ResourceRecords\": [
                                        {\"Value\": \"${instanceIP}\"}
                                    ],
                                    \"SetIdentifier\": \"${recordId}\",
                                    \"Failover\": \"${failoverRecordType}\"
                                }
                            }
                        ]
                    }"
                else
                    echo "Extraindo o ID da verificação de integridade $healthCheckName"
                    healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{
                        \"Changes\": [
                            {
                                \"Action\": \"CREATE\",
                                \"ResourceRecordSet\": {
                                    \"Name\": \"${resourceRecordName}\",
                                    \"Type\": \"${resourceRecordType}\",
                                    \"TTL\": ${ttl},
                                    \"ResourceRecords\": [
                                        {\"Value\": \"${instanceIP}\"}
                                    ],
                                    \"SetIdentifier\": \"${recordId}\",
                                    \"Failover\": \"${failoverRecordType}\",
                                    \"HealthCheckId\": \"${healthCheckId}\"
                                }
                            }
                        ]
                    }"
                fi

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            fi
        }


        function CreateRecordGLP() {hostedZoneId=$1 hostedZoneName=$2 resourceRecordName=$3 recordId=$4 resourceRecordType=$5 ttl=$6 tagNameInstance=$7 countryCode=$8 subdivisionCode=$9 region=${10}

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            condition=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].Name" --output text)
            if [ "$(echo $condition | wc -w)" -gt 0 ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o IP da instância $tagNameInstance"
                instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text)

                if [ -z "$subdivisionCode" ]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        \"Changes\": [
                            {
                                \"Action\": \"CREATE\",
                                \"ResourceRecordSet\": {
                                    \"Name\": \"${resourceRecordName}\",
                                    \"Type\": \"${resourceRecordType}\",
                                    \"TTL\": ${ttl},
                                    \"ResourceRecords\": [
                                        {\"Value\": \"${instanceIP}\"}
                                    ],
                                    \"SetIdentifier\": \"${recordId}\",
                                    \"GeoLocation\": {
                                        \"CountryCode\": \"${countryCode}\"
                                    }
                                }
                            }
                        ]
                    }"
                else
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        \"Changes\": [
                            {
                                \"Action\": \"CREATE\",
                                \"ResourceRecordSet\": {
                                    \"Name\": \"${resourceRecordName}\",
                                    \"Type\": \"${resourceRecordType}\",
                                    \"TTL\": ${ttl},
                                    \"ResourceRecords\": [
                                        {\"Value\": \"${instanceIP}\"}
                                    ],
                                    \"SetIdentifier\": \"${recordId}\",
                                    \"GeoLocation\": {
                                        \"CountryCode\": \"${countryCode}\",
                                        \"SubdivisionCode\": \"${subdivisionCode}\"
                                    }
                                }
                            }
                        ]
                    }"
                fi

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            fi
        }




        if [[ "$routingPolicy" == "SRP" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe a instância $tagNameInstance1"
            instance1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
            if [[ -n "$instance1" ]]; then
                CreateRecordSRP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -tagNameInstance "$tagNameInstance1"
            else
                echo "Não existe a instância $tagNameInstance1"
            fi
        elif [[ "$routingPolicy" == "FOP" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe a verificação de integridade $healthCheckName e as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            healthCheck=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text)
            instance1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region1" --output text)
            instance2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region2" --output text)
            if [[ -n "$healthCheck" && -n "$instance1" && -n "$instance2" ]]; then
                CreateRecordFOP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId1" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -failoverRecordType "$failoverRecordType1" -tagNameInstance "$tagNameInstance1" -healthCheckName "$healthCheckName" -region "$region1"
                CreateRecordFOP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId2" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -failoverRecordType "$failoverRecordType2" -tagNameInstance "$tagNameInstance2" -region "$region2"
            else
                echo "Não existe a verificação de integridade $healthCheckName ou as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            fi
        elif [[ "$routingPolicy" == "GLP" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            instance1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region1" --output text)
            instance2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region2" --output text)
            if [[ -n "$instance1" && -n "$instance2" ]]; then
                CreateRecordGLP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId1" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -tagNameInstance "$tagNameInstance1" -countryCode "$countryCode1" -subdivisionCode "$subdivisionCode1" -region "$region1"
                CreateRecordGLP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId2" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -tagNameInstance "$tagNameInstance2" -countryCode "$countryCode2" -region "$region2"
            else
                echo "Não existem as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            fi
        else
            echo "Não existe o tipo de roteamento $routingPolicy"
        fi
    else
        echo "Hosted zone $hostedZoneName não encontrada."
    fi
else
    echo "Código não executado"
fi




#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "RECORD ROUTING POLICIES-HOSTED ZONE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# domainName="hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
domainName="pedroheeger.dev.br"
$hostedZoneName = "$domainName."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
subdomain="www."
resourceRecordType="A"
ttl=300

# Simple Routing Policy (SRP)
# routingPolicy="SRP"
# subdomain="rsrp."
# tagNameInstance1="ec2Test1"

# Failover Policy (FOP)
# routingPolicy="FOP"
# subdomain="rfop."
# tagNameInstance1="ec2Test1"
# tagNameInstance2="ec2Test2"
# failoverRecordType1="PRIMARY"
# failoverRecordType2="SECONDARY"
# healthCheckName="healthCheckTest1"
# recordId1="Primary"
# recordId2="Secondary"

# Geolocation Policy (GLP)
routingPolicy="GLP"
# subdomain="rglp."
tagNameInstance1="ec2Test1"
tagNameInstance2="ec2Test2"
recordId1="US-NorthVirginia"
recordId2="Brasil-SP"
countryCode1="US"
subdivisionCode1="VA"
countryCode2="BR"
region1="us-east-1"
region2="sa-east-1"

resourceRecordName="$subdomain$domainName"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == "y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    condition=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text)
    if [[ $(echo "$condition" | wc -l) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id da hosted zone $hostedZoneName"
        hostedZoneId=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text)

        function DeleteRecordSRP() {hostedZoneId="$1" hostedZoneName="$2" resourceRecordName="$3" resourceRecordType="$4" ttl="$5" tagNameInstance="$6"
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o registro $resourceRecordName na hosted zone $hostedZoneName"
            condition=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text)
            if [[ $(echo "$condition" | wc -l) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[].Name" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe uma instância ativa $tagNameInstance"
                condition=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
                if [[ $(echo "$condition" | wc -l) -gt 0 ]]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Extraindo o IP da instância $tagNameInstance"
                    instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)
                else
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Extraindo o IP da instância $tagNameInstance configurado no registro $resourceRecordName"
                    instanceIP=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].ResourceRecords[].Value" --output text)
                fi

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{
                    \"Changes\": [
                        {
                            \"Action\": \"DELETE\",
                            \"ResourceRecordSet\": {
                                \"Name\": \"$resourceRecordName\",
                                \"Type\": \"$resourceRecordType\",
                                \"TTL\": $ttl,
                                \"ResourceRecords\": [
                                    {\"Value\": \"$instanceIP\"}
                                ]
                            }
                        }
                    ]
                }"
            else
                echo "Não existe o registro $resourceRecordName na hosted zone $hostedZoneName"
            fi
        }

        function DeleteRecordFOP() {hostedZoneId=$1 hostedZoneName=$2 resourceRecordName=$3 recordId=$4 resourceRecordType=$5 ttl=$6 failoverRecordType=$7 tagNameInstance=$8
            healthCheckName=$9 region="${10}"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            condition=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='${resourceRecordName}.' && SetIdentifier=='${recordId}'].Name" --output text)
            if [[ -n "$condition" ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='${resourceRecordName}.'].SetIdentifier" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe uma instância ativa $tagNameInstance"
                condition=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region --output text)
                if [[ -n "$condition" ]]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Extraindo o IP da instância $tagNameInstance"
                    instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text)
                else
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Extraindo o IP da instância $tagNameInstance configurado no registro $resourceRecordName"
                    instanceIP=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='${resourceRecordName}.' && SetIdentifier=='${recordId}'].ResourceRecords[].Value" --output text)
                fi

                if [[ -z "$healthCheckName" ]]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{\"Changes\":[{\"Action\":\"DELETE\",\"ResourceRecordSet\":{\"Name\":\"${resourceRecordName}\",\"Type\":\"${resourceRecordType}\",\"TTL\":${ttl},\"ResourceRecords\":[{\"Value\":\"${instanceIP}\"}],\"SetIdentifier\":\"${recordId}\",\"Failover\":\"${failoverRecordType}\"}}]}"
                else
                    echo "Extraindo o ID da verificação de integridade $healthCheckName"
                    healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='${healthCheckName}'].Id" --output text)

                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{\"Changes\":[{\"Action\":\"DELETE\",\"ResourceRecordSet\":{\"Name\":\"${resourceRecordName}\",\"Type\":\"${resourceRecordType}\",\"TTL\":${ttl},\"ResourceRecords\":[{\"Value\":\"${instanceIP}\"}],\"SetIdentifier\":\"${recordId}\",\"Failover\":\"${failoverRecordType}\",\"HealthCheckId\":\"${healthCheckId}\"}}]}"
                fi

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='${resourceRecordName}.'].SetIdentifier" --output text
            else
                echo "Não existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            fi
        }

        function DeleteRecordGLP() {hostedZoneId="$1" hostedZoneName="$2" resourceRecordName="$3" recordId="$4" resourceRecordType="$5" ttl="$6" tagNameInstance="$7" countryCode="$8"
            subdivisionCode="$9" region="${10}"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            condition=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].Name" --output text)
            if [[ $(echo "$condition" | wc -l) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe uma instância ativa $tagNameInstance"
                condition=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region" --output text)
                
                if [[ $(echo "$condition" | wc -l) -gt 0 ]]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Extraindo o IP da instância $tagNameInstance"
                    instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region "$region" --output text)
                else
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Extraindo o IP da instância $tagNameInstance configurado no registro $resourceRecordName"
                    instanceIP=$(aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='${resourceRecordName}.' && SetIdentifier=='$recordId'].ResourceRecords[].Value" --output text)
                fi

                if [ -z "$subdivisionCode" ]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{
                        \"Changes\": [
                            {
                                \"Action\": \"DELETE\",
                                \"ResourceRecordSet\": {
                                    \"Name\": \"${resourceRecordName}\",
                                    \"Type\": \"${resourceRecordType}\",
                                    \"TTL\": ${ttl},
                                    \"ResourceRecords\": [
                                        {\"Value\": \"${instanceIP}\"}
                                    ],
                                    \"SetIdentifier\": \"${recordId}\",
                                    \"GeoLocation\": {
                                        \"CountryCode\": \"${countryCode}\"
                                    }
                                }
                            }
                        ]
                    }"
                else
                   echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id "$hostedZoneId" --change-batch "{
                        \"Changes\": [
                            {
                                \"Action\": \"DELETE\",
                                \"ResourceRecordSet\": {
                                    \"Name\": \"${resourceRecordName}\",
                                    \"Type\": \"${resourceRecordType}\",
                                    \"TTL\": ${ttl},
                                    \"ResourceRecords\": [
                                        {\"Value\": \"${instanceIP}\"}
                                    ],
                                    \"SetIdentifier\": \"${recordId}\",
                                    \"GeoLocation\": {
                                        \"CountryCode\": \"${countryCode}\",
                                        \"SubdivisionCode\": \"${subdivisionCode}\"
                                    }
                                }
                            }
                        ]
                    }"
                fi

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id "$hostedZoneId" --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text
            else
                echo "Não existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            fi
        }




        if [[ "$routingPolicy" == "SRP" ]]; then
            # echo "-----//-----//-----//-----//-----//-----//-----"
            # echo "Verificando se existe a instância $tagNameInstance1"
            # conditionInstance=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text | wc -l)
            # if [[ $conditionInstance -gt 0 ]]; then
                DeleteRecordSRP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -tagNameInstance "$tagNameInstance1"
            # else
            #     echo "Não existe a instância $tagNameInstance1"
            # fi
        elif [[ "$routingPolicy" == "FOP" ]]; then
            # echo "-----//-----//-----//-----//-----//-----//-----"
            # echo "Verificando se existe a verificação de integridade $healthCheckName e as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            # conditionHealthCheck=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text | wc -l)
            # conditionInstance1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region1" --output text | wc -l)
            # conditionInstance2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region2" --output text | wc -l)
            # if [[ $conditionHealthCheck -gt 0 && $conditionInstance1 -gt 0 && $conditionInstance2 -gt 0 ]]; then
                DeleteRecordFOP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId1" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -failoverRecordType "$failoverRecordType1" -tagNameInstance "$tagNameInstance1" -healthCheckName "$healthCheckName" -region "$region1"
                DeleteRecordFOP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId2" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -failoverRecordType "$failoverRecordType2" -tagNameInstance "$tagNameInstance2" -region "$region2"
            # else
            #     echo "Não existe a verificação de integridade $healthCheckName ou as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            # fi
        elif [[ "$routingPolicy" == "GLP" ]]; then
            # echo "-----//-----//-----//-----//-----//-----//-----"
            # echo "Verificando se existe as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            # conditionInstance1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region1" --output text | wc -l)
            # conditionInstance2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region "$region2" --output text | wc -l)
            # if [[ $conditionInstance1 -gt 0 && $conditionInstance2 -gt 0 ]]; then
                DeleteRecordGLP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId1" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -tagNameInstance "$tagNameInstance1" -countryCode "$countryCode1" -subdivisionCode "$subdivisionCode1" -region "$region1"
                DeleteRecordGLP -hostedZoneId "$hostedZoneId" -hostedZoneName "$hostedZoneName" -resourceRecordName "$resourceRecordName" -recordId "$recordId2" -resourceRecordType "$resourceRecordType" -ttl "$ttl" -tagNameInstance "$tagNameInstance2" -countryCode "$countryCode2" -region "$region2"
            # else
            #     echo "Não existem as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            # fi
        else
            echo "Não existe o tipo de roteamento $routingPolicy"
        fi
    else
        echo "Não existe a hosted zone $hostedZoneName"
    fi
else
    echo "Código não executado"
fi