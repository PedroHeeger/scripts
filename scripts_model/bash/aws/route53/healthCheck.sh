#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "HEALTH CHECK CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="pedroheeger.dev.br."
healthCheckName="healthCheckTest3"
ipAddress="175.184.182.193"
portNumber=80
typeProtocol="HTTP"
resourcePath="/"
requestInterval=30      # Faz uma requisição para a instância a cada 30 segundos e considera a instância como não saudável se receber 3 falhas consecutivas.
failureThreshold=3
tagNameInstance="ec2Test1"
tagHealthCheck=$healthCheckName

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a verificação de integridade de nome $healthCheckName"
        if [ $(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe a verificação de integridade de nome $healthCheckName"
            aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o IP da instância $tagNameInstance"
            instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)
            # ipAddress=$instanceIP

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando a verificação de integridade de nome $healthCheckName"
            aws route53 create-health-check --caller-reference $healthCheckName --health-check-config "IPAddress=$ipAddress,Port=$portNumber,Type=$typeProtocol,ResourcePath=$resourcePath,RequestInterval=$requestInterval,FailureThreshold=$failureThreshold,EnableSNI=false" --no-cli-pager

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID da verificação de integridade de nome $healthCheckName"
            healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Adicionando uma tag de nome para a verificação de integridade de nome $healthCheckName"
            aws route53 change-tags-for-resource --resource-type healthcheck --resource-id $healthCheckId --add-tags "Key=Name,Value=$tagHealthCheck"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a verificação de integridade de nome $healthCheckName"
            aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text
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
echo "HEALTH CHECK EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
hostedZoneName="pedroheeger.dev.br."
healthCheckName="healthCheckTest2"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    if [ $(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a verificação de integridade de nome $healthCheckName"
        if [ $(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text | wc -l) -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text

            echo "Extraindo o ID da verificação de integridade de nome $healthCheckName"
            healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo a verificação de integridade de nome $healthCheckName"
            aws route53 delete-health-check --health-check-id $healthCheckId

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text
        else
            echo "Não existe a verificação de integridade de nome $healthCheckName"
        fi
    else
        echo "Não existe a hosted zone $hostedZoneName"
    fi
else
    echo "Código não executado"
fi