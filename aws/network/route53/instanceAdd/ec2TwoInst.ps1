#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2 E AWS ROUTE 53"
Write-Output "TWO INSTANCE CREATION FOR ROUTE 53"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2Test"
$instanceA = "1"
$instanceB = "2"
$az = "us-east-1a"
$otherAZ = "sa-east-1a"
$sgName = "default"
$imageIdA = "ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
$imageIdB = "ami-0f16d0d3ac759edfa"    # Canonical, Ubuntu, 24.04, amd64 noble image
$so = "ubuntu"
# $so = "ec2-user"
$instanceType = "t2.micro"
$keyPairPathA = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
$keyPairNameA = "keyPairUniversal"
$keyPairPathB = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/test"
$keyPairNameB = "keyPairTest"
$userDataPath = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd/"
$userDataFile = "udFileDeb.sh"
# $deviceName = "/dev/xvda" 
$deviceName = "/dev/sda1"
$volumeSize = 8
$volumeType = "gp2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    function CreateEC2Instance {
        param ([string]$tagNameInstance, [string]$instanceNum, [string]$region, [string]$keyPairPath, [string]$keyPairName, [string]$so, [string]$sgName, [string]$az, [string]$imageId, [string]$instanceType, [string]$userDataPath, [string]$userDataFile, [string]$deviceName, [string]$volumeSize, [string]$volumeType)
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a instância ativa ${tagNameInstance}${instanceNum}"
        $condition = aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceNum}')])].[Tags[?Key=='Name'].Value | [0]]" --region $region --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Já existe as instâncias ativas ${tagNameInstance}${instanceNum}"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceNum}'].Value" --region $region --output text
            
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o IP público da instância ativa ${tagNameInstance}${instanceNum}"
            $instanceIp = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text
            Write-Output $instanceIp
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id da instância ativa ${tagNameInstance}${instanceNum}"
            $instanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region --output text
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceNum}"
            Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" $so@$instanceIp"
            Write-Output "aws ssm start-session --target $instanceId"
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region $region --output text
        
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id dos elementos de rede para a instância ${tagNameInstance}${instanceNum}"
            $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --region $region --output text
            $subnetId = aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$az'].SubnetId" --region $region --output text
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Criando a instância ${tagNameInstance}${instanceNum}"
            $instanceId = aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $sgId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath\$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${tagNameInstance}${instanceNum}}]" --block-device-mappings "[{`"DeviceName`":`"$deviceName`",`"Ebs`":{`"VolumeSize`":$volumeSize,`"VolumeType`":`"$volumeType`"}}]" --no-cli-pager --query "Instances[0].InstanceId" --region $region --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Aguardando a instância criada entrar em execução"
            $instanceState = ""
              while ($instanceState -ne "running") {
                Start-Sleep -Seconds 20  
                $instanceState = aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager
                Write-Output "Estado atual da instância ${tagNameInstance}${instanceNum}: $instanceState"
            }

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region $region --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o IP público das instâncias ativas ${tagNameInstance}${instanceNum}"
            $instanceIp = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --region $region --output text
            Write-Output $instanceIp

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id das instâncias ativas ${tagNameInstance}${instanceNum}"
            $instanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceNum}"
            Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" $so@$instanceIp"
            Write-Output "aws ssm start-session --target $instanceId"
        }
    }


    if ($instanceA -lt  $instanceB) {
        $region = $az.Substring(0, $az.Length - 1)
        CreateEC2Instance -tagNameInstance $tagNameInstance -instanceNum $instanceA -region $region -keyPairPath $keyPairPathA -keyPairName $keyPairNameA -so $so -sgName $sgName -az $az -imageId $imageIdA -instanceType $instanceType -userDataPath $userDataPath -userDataFile $userDataFile -deviceName $deviceName -volumeSize $volumeSize -volumeType $volumeType
    } 
    if ($instanceB -gt $instanceA) {
        $region = $otherAZ.Substring(0, $otherAZ.Length - 1)
        CreateEC2Instance -tagNameInstance $tagNameInstance -instanceNum $instanceB -region $region -keyPairPath $keyPairPathB -keyPairName $keyPairNameB -so $so -sgName $sgName -az $other_az -imageId $imageIdB -instanceType $instanceType -userDataPath $userDataPath -userDataFile $userDataFile -deviceName $deviceName -volumeSize $volumeSize -volumeType $volumeType
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2 E AWS ROUTE 53"
Write-Output "TWO INSTANCE EXCLUSION FOR ROUTE 53"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2Test"
$instanceA = "1"
$instanceB = "2"
$az = "us-east-1a"
$otherAZ = "sa-east-1a"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    function DeleteEC2Instance {
        param ([string]$tagNameInstance, [string]$instanceNum, [string]$region)
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a instância ativa ${tagNameInstance}${instanceNum}"
        $condition = aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceNum}')])].[Tags[?Key=='Name'].Value | [0]]" --region $region --output text
        if (($condition).Count -gt 0) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region $region --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o Id da instância ativa ${tagNameInstance}${instanceNum}"
            $instanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceNum}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region $region --output text

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a instância ${tagNameInstance}${instanceNum}"
            aws ec2 terminate-instances --instance-ids $instanceId --no-dry-run --region $region --no-cli-pager
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Aguardando a instância ser removida"
            $instanceState = ""
            while ($instanceState -ne "terminated") {
                Start-Sleep -Seconds 20  
                $instanceState = aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[].Instances[].State.Name" --region $region --output text --no-cli-pager
                Write-Output "Estado atual da instância ${tagNameInstance}${instanceNum}: $instanceState"
            }

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando o nome de tag de todas as instâncias criadas ativas"
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --region $region --output text
        } else {Write-Output "Não existe a instância ativa ${tagNameInstance}${instanceNum}"}
    }


    if ($instanceA -lt  $instanceB) {
        $region = $az.Substring(0, $az.Length - 1)
        DeleteEC2Instance -tagNameInstance $tagNameInstance -instanceNum $instanceA -region $region
    }
    if ($instanceB -gt $instanceA) {
        $region = $otherAZ.Substring(0, $otherAZ.Length - 1)
        DeleteEC2Instance -tagNameInstance $tagNameInstance -instanceNum $instanceB -region $region
    }
} else {Write-Host "Código não executado"}