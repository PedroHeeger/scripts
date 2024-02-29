#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "LISTENER RULE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$albName = "albTest1"
$tgName = "tgTest1"
$listenerProtocol = "HTTP"
$listenerPort = "80"
$redirectProtocol = "HTTPS"
$redirectPort = 443
$listenerRuleName = "listenerRuleTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do load balancer $albName"
    $lbArn = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do target group $tgName"
    $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
    if ((aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do listener cujo protocolo é $listenerProtocol e a porta é $listenerPort"
        $listenerArn = aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
        if ((aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']]").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as regras do listener de protocolo $listenerProtocol e porta $listenerPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[].RuleArn" --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 create-rule --listener-arn $listenerArn --conditions "Field=path-pattern,Values=['/']" --priority 1 --actions "Type=redirect,RedirectConfig={Protocol=$redirectProtocol,Port=$redirectPort,StatusCode=HTTP_301}" --tags "Key=Name,Value=$listenerRuleName" --no-cli-pager
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando a regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text
        }
    } else {Write-Output "Não existe um listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-ELB"
Write-Output "LISTENER RULE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$albName = "albTest1"
$tgName = "tgTest1"
$listenerProtocol = "HTTP"
$listenerPort = "80"
$redirectProtocol = "HTTPS"
$redirectPort = 443

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do load balancer $albName"
    $lbArn = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Extraindo a ARN do target group $tgName"
    $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um listener vinculando o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"
    if ((aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a ARN do listener cujo protocolo é $listenerProtocol e a porta é $listenerPort"
        $listenerArn = aws elbv2 describe-listeners --load-balancer-arn $lbArn --query "Listeners[?to_string(Port)=='$listenerPort' && Protocol=='$listenerProtocol' && DefaultActions[?TargetGroupArn=='$tgArn']].ListenerArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe uma regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
        if ((aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']]").Count -gt 1) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as regras do listener de protocolo $listenerProtocol e porta $listenerPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[].RuleArn" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo a ARN da regra do listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            $listenerRuleArn = aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[?Actions[?Type == 'redirect' && RedirectConfig.Protocol == '$redirectProtocol']].RuleArn" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"
            aws elbv2 delete-rule --rule-arn $listenerRuleArn

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando todas as regras do listener de protocolo $listenerProtocol e porta $listenerPort"
            aws elbv2 describe-rules --listener-arn $listenerArn --query "Rules[].RuleArn" --output text
        } else {Write-Host "Não existe a regra no listener redirecionando o tráfego da porta $listenerPort para a porta $redirectPort"}
    } else {Write-Output "Não existe um listener que vincula o target group $tgName ao load balancer $albName na porta $listenerPort do protocolo $listenerProtocol"}
} else {Write-Host "Código não executado"}