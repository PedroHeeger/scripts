#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ELB"
Write-Output "LISTENER CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$albName = "albTest1"
$tgName = "tgTest1"
# $listenerProtocol = "HTTP"
# $listenerPort = "80"
$listenerProtocol = "HTTPS"
$listenerPort = "443"
$fullDomainName = "www.pedroheeger.dev.br"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o target group $tgName e o load balancer $albName"
    $condition = (aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text).Count -gt 0 -and (aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text).Count -gt 0
    if (($condition)) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do load balancer $albName"
        $lbArn = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do target group $tgName"
        $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
        $condition = aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os listeners do load balancer $albName"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text

            if ($listenerProtocol -eq "HTTPS") {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo a ARN do certificado de domínio $fullDomainName"
                $certificateArn = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$fullDomainName'].CertificateArn" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Criando um listener para vincular o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol com certificado"
                aws elbv2 create-listener --load-balancer-arn $lbArn --protocol $listenerProtocol --port $listenerPort --default-actions "Type=forward,TargetGroupArn=$tgArn" --certificates CertificateArn=$certificateArn --no-cli-pager
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Criando um listener para vincular o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
                aws elbv2 create-listener --load-balancer-arn $lbArn --protocol $listenerProtocol --port $listenerPort --default-actions "Type=forward,TargetGroupArn=$tgArn" --no-cli-pager
            }

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text
        }
    } else {Write-Output "Não existe o target group $tgName ou o load balancer $albName"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ELB"
Write-Output "LISTENER EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$albName = "albTest1"
$tgName = "tgTest1"
# $listenerProtocol = "HTTP"
# $listenerPort = "80"
$listenerProtocol = "HTTPS"
$listenerPort = "443"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o target group $tgName e o load balancer $albName"
    $condition = (aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text).Count -gt 0 -and (aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text).Count -gt 0
    if (($condition)) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do load balancer $albName"
        $lbArn = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do target group $tgName"
        $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
        $condition = aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os listeners do load balancer $albName"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo a ARN do listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            $listenerArn = aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
            aws elbv2 delete-listener --listener-arn $listenerArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todos os listeners do load balancer $albName"
            aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[].ListenerArn" --output text
        } else {Write-Output "Não existe um listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"}
    } else {Write-Output "Não existe o target group $tgName ou o load balancer $albName"}
} else {Write-Host "Código não executado"}