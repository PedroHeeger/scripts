#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "APPLICATION LOAD BALANCER (ALB) CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$albName = "albTest1"
$aZ1 = "us-east-1a"
$aZ2 = "us-east-1b"
$sgName = "default"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o load balancer de nome $albName"
    if ((aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o load balancer de nome $albName"
        aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os load balancers criados"
        aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os elementos de rede"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        $subnetId1 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $subnetId2 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ2" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $sgId = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" "Name=group-name,Values=$sgName" --query "SecurityGroups[].GroupId" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o load balancer de nome $albName"
        aws elbv2 create-load-balancer --name $albName --type application --scheme internet-facing --ip-address-type ipv4 --subnets $subnetId1 $subnetId2 --security-groups $sgId --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o load balancer de nome $albName"
        aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "APPLICATION LOAD BALANCER (ALB) EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$albName = "albTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o load balancer de nome $albName"
    if ((aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os load balancers criados"
        aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do load balancer de nome $tgName"
        $lbArn = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o load balancer de nome $albName"
        aws elbv2 delete-load-balancer --load-balancer-arn $lbArn

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os load balancers criados"
        aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName" --output text
    } else {Write-Output "Não existe o load balancer de nome $albName"}
} else {Write-Host "Código não executado"}