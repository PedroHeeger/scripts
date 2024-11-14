#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "HEALTH CHECK CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$healthCheckName = "healthCheckTest2"
$tagHealthCheck = $healthCheckName
$tagNameInstance = "ec2Test1"
$ipAddress = "175.184.182.193"
$portNumber = 80
$typeProtocol = "HTTP"
$resourcePath = "/"
$requestInterval = 30      # Faz uma requisição para a instância a cada 30 segundos e considera a instância como não saudável se receber 3 falhas consecutivas.
$failureThreshold = 3

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    $condition = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a verificação de integridade $healthCheckName"
        $condition = aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe a verificação de integridade $healthCheckName"
            aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe uma instância ativa $tagNameInstance"
            $condition = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo o IP da instância $tagNameInstance"
                $instanceIP = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
                $ipAddress = $instanceIP
            } else {Write-Output "Não existe uma instância ativa $tagNameInstance. Será utilizado o endereço de IP indicado."}

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando a verificação de integridade $healthCheckName"
            aws route53 create-health-check --caller-reference $healthCheckName --health-check-config "IPAddress=$ipAddress,Port=$portNumber,Type=$typeProtocol,ResourcePath=$resourcePath,RequestInterval=$requestInterval,FailureThreshold=$failureThreshold,EnableSNI=false" --no-cli-pager

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ID da verificação de integridade $healthCheckName"
            $healthCheckId = aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Adicionando uma tag para a verificação de integridade $healthCheckName"
            aws route53 change-tags-for-resource --resource-type healthcheck --resource-id $healthCheckId --add-tags "Key=Name,Value=$tagHealthCheck"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a verificação de integridade $healthCheckName"
            aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference" --output text
        }
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AMAZON ROUTE 53"
Write-Output "HEALTH CHECK EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
# $domainName = "hosted-zone-test1.com.br"     # Um domínio é o nome de um site ou serviço na internet
$domainName = "pedroheeger.dev.br"
$hostedZoneName = "$domainName."             # Hosted Zone é um container para esse domínio. Programaticamente ela aparece como o nome do domínio concatenado com um ponto
$healthCheckName = "healthCheckTest2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a hosted zone $hostedZoneName"
    $condition = aws route53 list-hosted-zones --query "HostedZones[?Name=='$hostedZoneName'].Name" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a verificação de integridade $healthCheckName"
        if ((aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].CallerReference").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o ID da verificação de integridade $healthCheckName"
            $healthCheckId = aws route53 list-health-checks --query "HealthChecks[?CallerReference=='$healthCheckName'].Id" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a verificação de integridade $healthCheckName"
            aws route53 delete-health-check --health-check-id $healthCheckId

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as verificações de integridade criadas"
            aws route53 list-health-checks --query "HealthChecks[].CallerReference" --output text
        } else {Write-Output "Não existe a verificação de integridade $healthCheckName"}    
    } else {Write-Output "Não existe a hosted zone $hostedZoneName"}
} else {Write-Host "Código não executado"}