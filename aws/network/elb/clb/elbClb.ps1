#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ELB"
Write-Output "CLASSIC LOAD BALANCER (CLB) CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clbName = "clbTest1"
$listenerProtocol = "HTTP"
$listenerPort = "80"
$instanceProtocol = "HTTP"
$instancePort = "80"
$az1 = "us-east-1a"
$az2 = "us-east-1b"
$sgName = "default"
$hcProtocol = "HTTP"
$hcPort = "80"
$hcPath = "index.html"
$hcIntervalSeconds = 15
$unhealthyThreshold = 2
$healthyThreshold = 5
$hcTimeoutSeconds = 5

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o classic load balancer $clbName"
    $condition = aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o classic load balancer $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ID dos elementos de rede"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupId" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o classic load balancer $clbName"
        aws elb create-load-balancer --load-balancer-name $clbName --listeners "Protocol=$listenerProtocol,LoadBalancerPort=$listenerPort,InstanceProtocol=$instanceProtocol,InstancePort=$instancePort" --availability-zones $az1 $az2 --security-groups $sgId

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a verificação de integridade do classic load balancer $clbName"
        aws elb configure-health-check --load-balancer-name $clbName --health-check "Target=${hcProtocol}:${hcPort}/${hcPath},Interval=$hcIntervalSeconds,UnhealthyThreshold=$unhealthyThreshold,HealthyThreshold=$healthyThreshold,Timeout=$hcTimeoutSeconds"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o classic load balancer $clbName"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ELB"
Write-Output "CLASSIC LOAD BALANCER (CLB) EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$clbName = "clbTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o classic load balancer $clbName"
    $condition = aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$clbName'].LoadBalancerName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o classic load balancer $clbName"
        aws elb delete-load-balancer --load-balancer-name $clbName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os classic load balancers criados"
        aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text
    } else {Write-Output "Não existe o classic load balancer $clbName"}
} else {Write-Host "Código não executado"}