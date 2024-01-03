#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "LISTENER CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$lbName = "lbTest1"
$tgName = "tgTest1"
$listenerProtocol = "HTTP"
$listenerPort = "80"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do load balancer $lbName"
    $lbArn = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$lbName'].LoadBalancerArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do target group $tgName"
    $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

    $condition = ((aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn").Count -gt 1 && (aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].DefaultActions[?TargetGroupArn=='$tgArn']").Count -gt 1)

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um listener vinculando o target group $tgName ao load balancer $lbName"
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe um listener vinculando o target group $tgName ao load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os listeners do load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um listener para vincular o target group $tgName ao load balancer $lbName"
        aws elbv2 create-listener --load-balancer-arn $lbArn --protocol $listenerProtocol --port $listenerPort --default-actions "Type=forward,TargetGroupArn=$tgArn" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o listener que vincula o target group $tgName ao load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "LISTENER EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$lbName = "lbTest1"
$tgName = "tgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do load balancer $lbName"
    $lbArn = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$lbName'].LoadBalancerArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do target group $tgName"
    $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

    $condition = ((aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn").Count -gt 1 && (aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].DefaultActions[?TargetGroupArn=='$tgArn']").Count -gt 1)

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um listener vinculando o target group $tgName ao load balancer $lbName"
    if ($condition) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os listeners do load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do listener que vincula o target group $tgName ao load balancer $lbName"
        $listenerArn = aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo listener que vincula o target group $tgName ao load balancer $lbName"
        aws elbv2 delete-listener --listener-arn $listenerArn

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os listeners do load balancer $lbName"
        aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
    } else {Write-Output "Não existe um listener que vincula o target group $tgName ao load balancer $lbName"}
} else {Write-Host "Código não executado"}