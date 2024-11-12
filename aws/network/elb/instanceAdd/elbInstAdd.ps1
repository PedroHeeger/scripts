#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2 E AWS ELB"
Write-Output "INSTANCE ADD TO ELB (CLB OR ALB)"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2ELBTest2"
# $elbName = "albTest1"
$elbName = "clbTest1"
$tgName = "tgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe uma instância ativa $tagNameInstance"
    $condition = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da instância $tagNameInstance"
        $instanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando o tipo de load balancer"
        $isClassicLB = $false
        $isApplicationLB = $false
        $classicLB = aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text
        $applicationLB = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text
        if (($classicLB).Count -gt 0) {$isClassicLB = $true} 
        elseif (($applicationLB).Count -gt 0) {$isApplicationLB = $true}   

        if ($isClassicLB) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se a instância $tagNameInstance está associada ao classic load balancer $elbName"
            $condition = aws elb describe-load-balancers --load-balancer-name $elbName --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Já existe a instância $tagNameInstance associada ao classic load balancer $elbName"
                aws elb describe-load-balancers --load-balancer-name $elbName --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text
            } else {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todas as instâncias associadas ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name $elbName --query "InstanceStates[].InstanceId" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Registrando a instância $tagNameInstance ao classic load balancer $elbName"
                aws elb register-instances-with-load-balancer --load-balancer-name $elbName --instances $instanceId

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando a instância $tagNameInstance associada ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name $elbName --query "InstanceStates[?InstanceId=='$instanceId'].InstanceId" --output text
            }
        }
        elseif ($isApplicationLB) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o target group $tgName"
            $condition = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo a ARN do target group $tgName"
                $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Verificando se existe a instância $tagNameInstance no target group $tgName"
                $condition = aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Já existe a instância $tagNameInstance no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text
                } else {       
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando todas as instâncias no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?TargetHealth.State!='draining'].Target.Id" --output text

                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Registrando a instância $tagNameInstance no target group $tgName"
                    aws elbv2 register-targets --target-group-arn $tgArn --targets Id=$instanceId

                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando a instância $tagNameInstance no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text
                }
            } else {Write-Output "Não existe o target group $tgName. A instância $tagNameInstance não pôde ser adicionadas. Certifique de criar o target group"}
        } else {Write-Output "Não existe o load balancer $elbName ou não pertence aos tipos Classic ou Application. A instância $tagNameInstance não foi vinculada ao load balancer"}
    } else {Write-Output "Não existe uma instância ativa $tagNameInstance"}
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2 E AWS ELB"
Write-Output "INSTANCE REMOVE TO ELB (CLB OR ALB)"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2ELBTest2"
# $elbName = "albTest1"
$elbName = "clbTest1"
$tgName = "tgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe uma instância ativa $tagNameInstance"
    $condition = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da instância $tagNameInstance"
        $instanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando o tipo de load balancer"
        $isClassicLB = $false
        $isApplicationLB = $false
        $classicLB = aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text
        $applicationLB = aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text
        if (($classicLB).Count -gt 0) {$isClassicLB = $true} 
        elseif (($applicationLB).Count -gt 0) {$isApplicationLB = $true}   

        if ($isClassicLB) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se a instância $tagNameInstance está associada ao classic load balancer $elbName"
            $condition = aws elb describe-load-balancers --load-balancer-name $elbName --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todas as instâncias associadas ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name $elbName --query "InstanceStates[].InstanceId" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Removendo a instância $tagNameInstance associada ao classic load balancer $elbName"
                aws elb deregister-instances-from-load-balancer --load-balancer-name $elbName --instances $instanceId

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Listando todas as instâncias associadas ao classic load balancer $elbName"
                aws elb describe-instance-health --load-balancer-name $elbName --query "InstanceStates[].InstanceId" --output text
            } else {Write-Output "Não existe a instância $tagNameInstance associada ao classic load balancer $elbName"}
        }
        elseif ($isApplicationLB) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Verificando se existe o target group $tgName"
            $condition = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text
            if (($condition).Count -gt 0) {
                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Extraindo a ARN do target group $tgName"
                $tgArn = aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text

                Write-Output "-----//-----//-----//-----//-----//-----//-----"
                Write-Output "Verificando se existe a instância $tagNameInstance no target group $tgName"
                $condition = aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?Target.Id=='$instanceId' && TargetHealth.State!='draining'].Target.Id" --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando todas as instâncias no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?TargetHealth.State!='draining'].Target.Id" --output text
        
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Removendo a instância $tagNameInstance no target group $tgName"
                    aws elbv2 deregister-targets --target-group-arn $tgArn --targets Id=$instanceId
        
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Listando todas as instâncias no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?TargetHealth.State!='draining'].Target.Id" --output text
                } else {Write-Output "Não existe a instância $tagNameInstance no target group $tgName"}
            } else {Write-Output "Não existe o target group $tgName."}
        } else {Write-Output "Não existe o load balancer $elbName ou não pertence aos tipos Classic ou Application"}
    } else {Write-Output "Não existe uma instância ativa $tagNameInstance"}
} else {Write-Host "Código não executado"}