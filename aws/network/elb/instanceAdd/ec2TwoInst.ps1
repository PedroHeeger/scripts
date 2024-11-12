#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2 E AWS ELB"
Write-Output "TWO INSTANCE CREATION AND ADD AO ELB (CLB OU ALB)"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2ELBTest"
$instanceA = "1"
$instanceB = "2"
$sgName = "default"
$az = "us-east-1a"
$imageId = "ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
$so = "ubuntu"
# $so = "ec2-user"
$instanceType = "t2.micro"
$keyPairPath = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
$keyPairName = "keyPairUniversal"
$userDataPath = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd/"
$userDataFile = "udFileDeb.sh"
# $deviceName = "/dev/xvda" 
$deviceName = "/dev/sda1"
$volumeSize = 8
$volumeType = "gp2"
$elbName = "albTest1"
# $elbName = "clbTest1"
$tgName = "tgTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    function addInstanceLb {
        param ([string]$elbName, [string]$tgName, [string]$tagNameInstance, [string]$instanceId)
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
                Write-Output "Registrando a instância $tagNameInstance ao classic load balancer $elbName"
                aws elb register-instances-with-load-balancer --load-balancer-name $elbName --instances $instanceId
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
                $condition = aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id" --output text
                if (($condition).Count -gt 0) {
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Já existe a instância $tagNameInstance no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn $tgArn --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id" --output text
                } else {           
                    Write-Output "-----//-----//-----//-----//-----//-----//-----"
                    Write-Output "Registrando a instância $tagNameInstance no target group $tgName"
                    aws elbv2 register-targets --target-group-arn $tgArn --targets Id=$instanceId
                }
            } else {Write-Output "Não existe o target group $tgName. A instância $tagNameInstance não pôde ser adicionadas. Certifique de criar o target group."}
        } else {Write-Output "Não existe o load balancer $elbName ou não pertence aos tipos Classic e Application. A instância $tagNameInstance não foi vinculada ao load balancer."}
    }



    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe as instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
    $condition = aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceA}' || Value=='${tagNameInstance}${instanceB}')])].[Tags[?Key=='Name'].Value | [0]]" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe as instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceA}'].Value" --output text
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceB}'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        $instanceIpA = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
        $instanceIpB = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
        Write-Output $instanceIpA
        Write-Output $instanceIpB

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        $instanceIdA = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text
        $instanceIdB = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceA}"
        Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" $so@$instanceIpA"
        Write-Output "aws ssm start-session --target $instanceIdA"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceB}"
        Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" $so@$instanceIpB"
        Write-Output "aws ssm start-session --target $instanceIdB"
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Adicionando as instâncias ao load balancer $elbName"
        addInstanceLb -elbName $elbName -tgName $tgName -tagNameInstance ${tagNameInstance}${instanceA} -instanceId $instanceIdA
        addInstanceLb -elbName $elbName -tgName $tgName -tagNameInstance ${tagNameInstance}${instanceB} -instanceId $instanceIdB
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id dos elementos de rede"
        $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text
        $subnetId = aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$az'].SubnetId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância ${tagNameInstance}${instanceA}"
        $instanceIdA = aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $sgId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath\$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${tagNameInstance}${instanceA}}]" --block-device-mappings "[{`"DeviceName`":`"$deviceName`",`"Ebs`":{`"VolumeSize`":$volumeSize,`"VolumeType`":`"$volumeType`"}}]" --no-cli-pager --query "Instances[0].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância ${tagNameInstance}${instanceB}"
        $instanceIdB = aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $sgId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath\$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${tagNameInstance}${instanceB}}]" --block-device-mappings "[{`"DeviceName`":`"$deviceName`",`"Ebs`":{`"VolumeSize`":$volumeSize,`"VolumeType`":`"$volumeType`"}}]" --no-cli-pager --query "Instances[0].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Aguardando as instâncias criadas entrarem em execução"
        $instanceStateA = ""
        $instanceStateB = ""
        while ($instanceStateA -ne "running" -or $instanceStateB -ne "running") {
            Start-Sleep -Seconds 20  
            $instanceStateA = aws ec2 describe-instances --instance-ids $instanceIdA --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager
            Write-Output "Estado atual da instância ${tagNameInstance}${instanceA}: $instanceStateA"
            $instanceStateB = aws ec2 describe-instances --instance-ids $instanceIdB --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager
            Write-Output "Estado atual da instância ${tagNameInstance}${instanceB}: $instanceStateB"
        }

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        $instanceIpA = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
        $instanceIpB = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
        Write-Output $instanceIpA
        Write-Output $instanceIpB

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        $instanceIdA = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text
        $instanceIdB = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceA}"
        Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" $so@$instanceIpA"
        Write-Output "aws ssm start-session --target $instanceIdA"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceB}"
        Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" $so@$instanceIpB"
        Write-Output "aws ssm start-session --target $instanceIdB"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Adicionando as instâncias ao load balancer $elbName"
        addInstanceLb -elbName $elbName -tgName $tgName -tagNameInstance ${tagNameInstance}${instanceA} -instanceId $instanceIdA
        addInstanceLb -elbName $elbName -tgName $tgName -tagNameInstance ${tagNameInstance}${instanceB} -instanceId $instanceIdB
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "TWO INSTANCE EXCLUSION AND REMOVE DO ELB (CLB OU ALB)"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2ELBTest"
$instanceA = "1"
$instanceB = "2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe as instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
    $condition = aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceA}' || Value=='${tagNameInstance}${instance}2')])].[Tags[?Key=='Name'].Value | [0]]" --output text
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        $instanceIdA = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" --query "Reservations[].Instances[].InstanceId" --output text
        $instanceIdB = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo as instâncias ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 terminate-instances --instance-ids $instanceIdA $instanceIdB --no-dry-run --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Aguardando as instâncias serem removidas"
        $instanceStateA = ""
        $instanceStateB = ""
        while ($instanceStateA -ne "terminated" -or $instanceStateB -ne "terminated") {
            Start-Sleep -Seconds 20  
            $instanceStateA = aws ec2 describe-instances --instance-ids $instanceIdA --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager
            Write-Output "Estado atual da instância ${tagNameInstance}${instanceA}: $instanceStateA"
            $instanceStateB = aws ec2 describe-instances --instance-ids $instanceIdA --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager
            Write-Output "Estado atual da instância ${tagNameInstance}${instanceB}: $instanceStateB"
        }
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    } else {Write-Output "Não existem instâncias ativas ${tagNameInstance}${instanceA} ou ${tagNameInstance}${instanceB}"}
} else {Write-Host "Código não executado"}