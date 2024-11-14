#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON ROUTE 53"
echo "HEALTH CHECK CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
tagHealthCheck=$healthCheckName
healthCheckName="healthCheckTest1"
tagNameInstance="ec2Test1"
ipAddress="175.184.182.193"
portNumber=80
typeProtocol="HTTP"
resourcePath="/"
requestInterval=30      # Faz uma requisição para a instância a cada 30 segundos e considera a instância como não saudável se receber 3 falhas consecutivas.
failureThreshold=3

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    condition=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a verificação de integridade $healthCheckName"
        condition=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe a verificação de integridade $healthCheckName"
            aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe uma instância ativa $tagNameInstance"
            condition=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text | wc -l)
            if [[ "$condition" -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o IP da instância $tagNameInstance"
                instanceIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)
                ipAddress=$instanceIP
            else
                echo "Não existe uma instância ativa $tagNameInstance. Será utilizado o endereço de IP indicado."
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando a verificação de integridade $healthCheckName"
            aws route53 create-health-check --caller-reference $healthCheckName --health-check-config "IPAddress=$ipAddress,Port=$portNumber,Type=$typeProtocol,ResourcePath=$resourcePath,RequestInterval=$requestInterval,FailureThreshold=$failureThreshold,EnableSNI=false" --no-cli-pager

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o ID da verificação de integridade $healthCheckName"
            healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Adicionando uma tag para a verificação de integridade $healthCheckName"
            aws route53 change-tags-for-resource --resource-type healthcheck --resource-id $healthCheckId --add-tags "Key=Name,Value=$tagHealthCheck"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a verificação de integridade $healthCheckName"
            aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text
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
echo "HEALTH CHECK EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
domainName="hosted-zone-test1.com.br"      # Um domínio é o nome de um site ou serviço na internet
# domainName="pedroheeger.dev.br"
hostedZoneName="${domainName}."            # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
healthCheckName="healthCheckTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a hosted zone $hostedZoneName"
    condition=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a verificação de integridade $healthCheckName"
        condition=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text

            echo "Extraindo o ID da verificação de integridade $healthCheckName"
            healthCheckId=$(aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo a verificação de integridade $healthCheckName"
            aws route53 delete-health-check --health-check-id $healthCheckId

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text
        else
            echo "Não existe a verificação de integridade $healthCheckName"
        fi
    else
        echo "Não existe a hosted zone $hostedZoneName"
    fi
else
    echo "Código não executado"
fi