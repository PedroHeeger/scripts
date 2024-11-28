#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD ROUTING POLICIES-HOSTED ZONE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$subdomain = "www."
$resourceRecordType = "A"
$ttl = 300

# Simple Routing Policy (SRP)
# $routingPolicy = "SRP"
# # $subdomain = "rsrp."
# $tagNameInstance1 = "ec2Test1"

# Failover Policy (FOP)
$routingPolicy = "FOP"
# $subdomain = "rfop."
$tagNameInstance1 = "ec2Test1"
$tagNameInstance2 = "ec2Test2"
$failoverRecordType1 = "PRIMARY"   # PRIMARY OR SECONDARY
$failoverRecordType2 = "SECONDARY"   # PRIMARY OR SECONDARY
$healthCheckName = "healthCheckTest1"
$recordId1 = "Primary"
$recordId2 = "Secondary"
$region1 = "us-east-1"
$region2 = "sa-east-1"

# Geolocation Policy (GLP)
# $routingPolicy = "GLP"
# # $subdomain = "rglp."
# $tagNameInstance1 = "ec2Test1"
# $tagNameInstance2 = "ec2Test2"
# $recordId1 = "US-NorthVirginia"
# $recordId2 = "Brasil-SP"
# $countryCode1 = "US"
# $subdivisionCode1 = "VA"
# $countryCode2 = "BR"
# # $countryCode2 = "FR"
# $region1 = "us-east-1"
# $region2 = "sa-east-1"

$resourceRecordName = "$subdomain$domainName"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    if ((aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        function CreateRecordSRP {
            param ([string]$hostedZoneId, [string]$hostedZoneName, [string]$resourceRecordName, [string]$resourceRecordType, [int]$ttl, [string]$tagNameInstance)
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro $resourceRecordName na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo o IP da instância $tagNameInstance"
                $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text        

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Criando o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                    `"Changes`": [
                    {
                        `"Action`": `"CREATE`",
                        `"ResourceRecordSet`": {
                        `"Name`": `"${resourceRecordName}`",
                        `"Type`": `"${resourceRecordType}`",
                        `"TTL`": ${ttl},
                        `"ResourceRecords`": [
                            {`"Value`": `"${instanceIP}`"}
                        ]
                        }
                    }
                    ]
                }"

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
            }
        }
        

        function CreateRecordFOP {
            param ([string]$hostedZoneId, [string]$hostedZoneName, [string]$resourceRecordName, [string]$recordId, [string]$resourceRecordType, [int]$ttl, [string]$failoverRecordType, [string]$tagNameInstance, [string]$region, [string]$healthCheckName)
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].Name" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo o IP da instância $tagNameInstance"
                $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text

                if ([string]::IsNullOrEmpty($healthCheckName)) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"CREATE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`"}
                            ],
                            `"SetIdentifier`": `"${recordId}`",
                            `"Failover`": `"${failoverRecordType}`"
                            }
                        }
                        ]
                    }"
                } else {
                    Write-Output "Extraindo o ID da verificação de integridade $healthCheckName"
                    $healthCheckId = aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text
            
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"CREATE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`" }
                            ],
                            `"SetIdentifier`": `"${recordId1}`",
                            `"Failover`": `"${failoverRecordType}`",
                            `"HealthCheckId`": `"${healthCheckId}`"
                            }
                        }
                        ]
                    }"
                }

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            }
        }
        
        function CreateRecordGLP {
            param ([string]$hostedZoneId, [string]$hostedZoneName, [string]$resourceRecordName, [string]$recordId, [string]$resourceRecordType, [int]$ttl, [string]$tagNameInstance, [string]$countryCode, [string]$subdivisionCode, [string]$region)
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].Name" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo o IP da instância $tagNameInstance"
                $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text

                if ([string]::IsNullOrEmpty($subdivisionCode)) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"CREATE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`"}
                            ],
                            `"SetIdentifier`": `"${recordId}`",
                            `"GeoLocation`": {
                                `"CountryCode`": `"${countryCode}`"
                            }
                            }
                        }
                        ]
                    }"
                } else {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Criando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"CREATE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`"}
                            ],
                            `"SetIdentifier`": `"${recordId}`",
                            `"GeoLocation`": {
                                `"CountryCode`": `"${countryCode}`",
                                `"SubdivisionCode`": `"${subdivisionCode}`"
                            }
                            }
                        }
                        ]
                    }"
                }

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].SetIdentifier" --output text
            }
        }




        if ($routingPolicy -eq "SRP") {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe a instância $tagNameInstance1"
            $condition = (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text).Count -gt 0
            if (($condition)) {
                CreateRecordSRP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -resourceRecordType $resourceRecordType -ttl $ttl -tagNameInstance $tagNameInstance1
            } else {Write-Output "Não existe a hosted zone $hostedZoneName ou a instância $tagNameInstance1"}  
        } elseif ($routingPolicy -eq "FOP") {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe a verificação de integridade $healthCheckName e as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            $condition = ((aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region1 --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region2 --output text).Count -gt 0)
            if (($condition)) {
                CreateRecordFOP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId1 -resourceRecordType $resourceRecordType -ttl $ttl -failoverRecordType $failoverRecordType1 -tagNameInstance $tagNameInstance1 -region $region1 -healthCheckName $healthCheckName
    
                CreateRecordFOP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId2 -resourceRecordType $resourceRecordType -ttl $ttl -failoverRecordType $failoverRecordType2 -tagNameInstance $tagNameInstance2 -region $region2
            } else {Write-Output "Não existe a verificação de integridade $healthCheckName ou as instâncias ativas $tagNameInstance1 e $tagNameInstance2"}    
        } elseif ($routingPolicy -eq "GLP") {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            $condition = ((aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region1 --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region2 --output text).Count -gt 0)
            if (($condition)) {
                CreateRecordGLP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId1 -resourceRecordType $resourceRecordType -ttl $ttl -tagNameInstance $tagNameInstance1 -countryCode $countryCode1 -subdivisionCode $subdivisionCode1 -region $region1
    
                CreateRecordGLP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId2 -resourceRecordType $resourceRecordType -ttl $ttl -tagNameInstance $tagNameInstance2 -countryCode $countryCode2 -region $region2
            } else {Write-Output "Não existem as instâncias ativas $tagNameInstance1 e $tagNameInstance2"}  
        } else {Write-Output "Não existe o tipo de roteamento $routingPolicy"}
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "RECORD ROUTING POLICIES-HOSTED ZONE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$subdomain = "www."
$resourceRecordType = "A"
$ttl = 300

# Simple Routing Policy (SRP)
# $routingPolicy = "SRP"
# # $subdomain = "rsrp."
# $tagNameInstance1 = "ec2Test1"

# Failover Policy (FOP)
$routingPolicy = "FOP"
# $subdomain = "rfop."
$tagNameInstance1 = "ec2Test1"
$tagNameInstance2 = "ec2Test2"
$failoverRecordType1 = "PRIMARY"   # PRIMARY OR SECONDARY
$failoverRecordType2 = "SECONDARY"   # PRIMARY OR SECONDARY
$healthCheckName = "healthCheckTest1"
$recordId1 = "Primary"
$recordId2 = "Secondary"
$region1 = "us-east-1"
$region2 = "sa-east-1"

# Geolocation Policy (GLP)
# $routingPolicy = "GLP"
# # $subdomain = "rglp."
# $tagNameInstance1 = "ec2Test1"
# $tagNameInstance2 = "ec2Test2"
# $recordId1 = "US-NorthVirginia"
# $recordId2 = "Brasil-SP"
# $countryCode1 = "US"
# $subdivisionCode1 = "VA"
# $countryCode2 = "BR"
# # $countryCode2 = "FR"
# $region1 = "us-east-1"
# $region2 = "sa-east-1"

$resourceRecordName = "$subdomain$domainName"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    if ((aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da hosted zone $hostedZoneName"
        $hostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Id" --output text

        function DeleteRecordSRP {
            param ([string]$hostedZoneId, [string]$hostedZoneName, [string]$resourceRecordName, [string]$resourceRecordType, [int]$ttl, [string]$tagNameInstance)
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro $resourceRecordName na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].Name" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Verificando se existe uma instância ativa $tagNameInstance"
                $condition = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Extraindo o IP da instância $tagNameInstance"
                    $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
                } else {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Extraindo o IP da instância $tagNameInstance configurado no registro $resourceRecordName"
                    $instanceIP = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.'].ResourceRecords[].Value" --output text
                }
        
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Removendo o registro $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                    `"Changes`": [
                    {
                        `"Action`": `"DELETE`",
                        `"ResourceRecordSet`": {
                        `"Name`": `"${resourceRecordName}`",
                        `"Type`": `"${resourceRecordType}`",
                        `"TTL`": ${ttl},
                        `"ResourceRecords`": [
                            {`"Value`": `"${instanceIP}`"}
                        ]
                        }
                    }
                    ]
                }"
    
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[].Name" --output text
            } else {Write-Output "Não existe o registro $resourceRecordName na hosted zone $hostedZoneName"}  
        }
        

        function DeleteRecordFOP {
            param ([string]$hostedZoneId, [string]$hostedZoneName, [string]$resourceRecordName, [string]$recordId, [string]$resourceRecordType, [int]$ttl, [string]$failoverRecordType, [string]$tagNameInstance, [string]$region, [string]$healthCheckName)
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].Name" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Verificando se existe uma instância ativa $tagNameInstance"
                $condition = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Extraindo o IP da instância $tagNameInstance"
                    $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text
                } else {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Extraindo o IP da instância $tagNameInstance configurado no registro $resourceRecordName"
                    $instanceIP = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.' && SetIdentifier=='$recordId'].ResourceRecords[].Value" --output text
                }
        
                if ([string]::IsNullOrEmpty($healthCheckName)) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"DELETE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`"}
                            ],
                            `"SetIdentifier`": `"${recordId}`",
                            `"Failover`": `"${failoverRecordType}`"
                            }
                        }
                        ]
                    }"
                } else {
                    Write-Output "Extraindo o ID da verificação de integridade $healthCheckName"
                    $healthCheckId = aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text
                    
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"DELETE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`"}
                            ],
                            `"SetIdentifier`": `"${recordId}`",
                            `"Failover`": `"${failoverRecordType}`",
                            `"HealthCheckId`": `"${healthCheckId}`"
                            }
                        }
                        ]
                    }"
                }
    
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text
            } else {Write-Output "Não existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"}  
        }
        

        function DeleteRecordGLP {
            param ([string]$hostedZoneId, [string]$hostedZoneName, [string]$resourceRecordName, [string]$recordId, [string]$resourceRecordType, [int]$ttl, [string]$tagNameInstance, [string]$countryCode, [string]$subdivisionCode, [string]$region)
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
            $condition = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.' && SetIdentifier=='$recordId'].Name" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Verificando se existe uma instância ativa $tagNameInstance"
                $condition = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Extraindo o IP da instância $tagNameInstance"
                    $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text
                } else {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Extraindo o IP da instância $tagNameInstance configurado no registro $resourceRecordName"
                    $instanceIP = aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='${resourceRecordName}.' && SetIdentifier=='$recordId'].ResourceRecords[].Value" --output text
                }
                
                if ([string]::IsNullOrEmpty($subdivisionCode)) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"DELETE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`"}
                            ],
                            `"SetIdentifier`": `"${recordId}`",
                            `"GeoLocation`": {
                                `"CountryCode`": `"${countryCode}`"
                            }
                            }
                        }
                        ]
                    }"
                } else {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Removendo o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"
                    aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch "{
                        `"Changes`": [
                        {
                            `"Action`": `"DELETE`",
                            `"ResourceRecordSet`": {
                            `"Name`": `"${resourceRecordName}`",
                            `"Type`": `"${resourceRecordType}`",
                            `"TTL`": ${ttl},
                            `"ResourceRecords`": [
                                {`"Value`": `"${instanceIP}`"}
                            ],
                            `"SetIdentifier`": `"${recordId}`",
                            `"GeoLocation`": {
                                `"CountryCode`": `"${countryCode}`",
                                `"SubdivisionCode`": `"${subdivisionCode}`"
                            }
                            }
                        }
                        ]
                    }"
                }

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todos os registros $resourceRecordName na hosted zone $hostedZoneName"
                aws route53 list-resource-record-sets --hosted-zone-id $hostedZoneId --query "ResourceRecordSets[?Name=='$resourceRecordName.'].SetIdentifier" --output text
            } else {Write-Output "Não existe o registro $resourceRecordName com identificador $recordId na hosted zone $hostedZoneName"}  
        }




        if ($routingPolicy -eq "SRP") {
            # Write-Output "-----//-----//-----//-----//-----//-----//-----"
            # Write-Output "Verificando se existe a instância $tagNameInstance1"
            # $condition = (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text).Count -gt 0
            # if (($condition)) {
                DeleteRecordSRP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -resourceRecordType $resourceRecordType -ttl $ttl -tagNameInstance $tagNameInstance1
            # } else {Write-Output "Não existe a instância $tagNameInstance1"}  
        } elseif ($routingPolicy -eq "FOP") {
            # Write-Output "-----//-----//-----//-----//-----//-----//-----"
            # Write-Output "Verificando se existe a verificação de integridade $healthCheckName e as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            # $condition = ((aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region1 --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region2 --output text).Count -gt 0)
            # if (($condition)) {
                DeleteRecordFOP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId1 -resourceRecordType $resourceRecordType -ttl $ttl -failoverRecordType $failoverRecordType1 -tagNameInstance $tagNameInstance1 -region $region1 -healthCheckName $healthCheckName
    
                DeleteRecordFOP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId2 -resourceRecordType $resourceRecordType -ttl $ttl -failoverRecordType $failoverRecordType2 -tagNameInstance $tagNameInstance2 -region $region2
            # } else {Write-Output "Não existe a verificação de integridade $healthCheckName ou as instâncias ativas $tagNameInstance1 e $tagNameInstance2"}    
        } elseif ($routingPolicy -eq "GLP") {
            # Write-Output "-----//-----//-----//-----//-----//-----//-----"
            # Write-Output "Verificando se existe as instâncias ativas $tagNameInstance1 e $tagNameInstance2"
            # $condition = ((aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance1" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region1 --output text).Count -gt 0 -and (aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region2 --output text).Count -gt 0)
            # if (($condition)) {
                DeleteRecordGLP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId1 -resourceRecordType $resourceRecordType -ttl $ttl -tagNameInstance $tagNameInstance1 -countryCode $countryCode1 -subdivisionCode $subdivisionCode1 -region $region1
    
                DeleteRecordGLP -hostedZoneId $hostedZoneId -hostedZoneName $hostedZoneName -resourceRecordName $resourceRecordName -recordId $recordId2 -resourceRecordType $resourceRecordType -ttl $ttl -tagNameInstance $tagNameInstance2 -countryCode $countryCode2 -region $region2
            # } else {Write-Output "Não existem as instâncias ativas $tagNameInstance1 e $tagNameInstance2"}  
        } else {Write-Output "Não existe o tipo de roteamento $routingPolicy"}
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}