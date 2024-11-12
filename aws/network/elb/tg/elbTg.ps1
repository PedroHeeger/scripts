#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ELB"
Write-Output "TARGET GROUP CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tgName = "tgTest1"
$tgType = "instance"
# $tgType = "ip"
$tgProtocol = "HTTP"
$tgProtocolVersion = "HTTP1"
$tgPort = 80
$tgHealthCheckProtocol = "HTTP"
$tgHealthCheckPort = "traffic-port"
$tgHealthCheckPath = "/"
$healthyThreshold = 5
$unhealthyThreshold = 2
$hcTimeoutSeconds = 5
$hcIntervalSeconds = 15
$hcMatcher = "HttpCode=200-299"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o target group $tgName"
    $condition = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o target group $tgName"
        aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os target groups criados"
        aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da VPC padrão"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando o target group $tgName"
        aws elbv2 create-target-group --name $tgName --target-type $tgType --protocol $tgProtocol --protocol-version $tgProtocolVersion --port $tgPort --vpc-id $vpcId --health-check-protocol $tgHealthCheckProtocol --health-check-port $tgHealthCheckPort --health-check-path $tgHealthCheckPath --healthy-threshold $healthyThreshold --unhealthy-threshold $unhealthyThreshold --health-check-timeout-seconds $hcTimeoutSeconds --health-check-interval-seconds $hcIntervalSeconds --matcher $hcMatcher --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o target group $tgName"
        aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ELB"
Write-Output "TARGET GROUP EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tgName = "tgTest1"
$albName = "albTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o target group $tgName"
    $condition = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os target groups criados"
        aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o load balancer $albName"
        $condition = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$albName'].LoadBalancerName" --output text
        if (($condition).Count -gt 0) {Write-Output "Necessário excluir o load balancer $albName antes de excluir o target group $tgName"}
        else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo a ARN do target group $tgName"
            $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o target group $tgName"
            aws elbv2 delete-target-group --target-group-arn $tgArn
        }

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os target groups criados"
        aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupName" --output text
    } else {Write-Output "Não existe o target group $tgName"}
} else {Write-Host "Código não executado"}