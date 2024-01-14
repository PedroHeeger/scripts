#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "CLASSIC LOAD BALANCER (CLB) CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clbName = "clbTest1"
$listenerProtocol = "HTTP"
$listenerPort = "80"
$instanceProtocol = "HTTP"
$instancePort = "80"
$aZ1 = "us-east-1a"
$aZ2 = "us-east-1b"
$groupName = "default"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o classic load balancer de nome $clbName"
    if ((aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o classic load balancer de nome $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ID do grupo de segurança"
        $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$groupName" --query "SecurityGroups[].GroupId" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o classic load balancer de nome $clbName"
        aws elb create-load-balancer --load-balancer-name $clbName --listeners "Protocol=$listenerProtocol,LoadBalancerPort=$listenerPort,InstanceProtocol=$instanceProtocol,InstancePort=$instancePort" --availability-zones $aZ1 $aZ2 --security-groups $sgId

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a verificação de integridade do classic load balancer de nome $clbName"
        aws elb configure-health-check --load-balancer-name $clbName --health-check "Target=${listenerProtocol}:${listenerPort}/index.html,Interval=15,UnhealthyThreshold=2,HealthyThreshold=5,Timeout=5"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o classic load balancer de nome $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "CLASSIC LOAD BALANCER (CLB) EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clbName = "clbTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o classic load balancer de nome $clbName"
    if ((aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o classic load balancer de nome $clbName"
        aws elb delete-load-balancer --load-balancer-name $clbName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text
    } else {Write-Output "Não existe o classic load balancer de nome $clbName"}
} else {Write-Host "Código não executado"}