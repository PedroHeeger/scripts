#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "EC2 CREATION WITH DOCKER CONNECTED WITH ECR"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2Test1"
$groupName = "default"
$aZ = "us-east-1a"
$imageId = "ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
$instanceType = "t2.micro"
$keyPairPath = "G:\Meu Drive\4_PROJ\scripts\scripts_model\.default\secrets\awsKeyPair"
$keyPairName = "keyPairUniversal"
$userDataPath = "G:\Meu Drive\4_PROJ\scripts\scripts_model\power_shell\aws\ecr\suport"
$userDataFile = "udFileTest.sh"
# $awsCliPath = "G:\Meu Drive\4_PROJ\scripts\scripts_model\.default\secrets\awscli\iamUserWorker\"
# $awsCliFolder = ".aws"
# $vmPath = "/home/ubuntu"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância $tagNameInstance"
    if ((aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe uma instância EC2 com o nome de tag $tagNameInstance"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='$tagNameInstance'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público da instância $tagNameInstance"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os Ids do grupo de segurança e sub-redes padrões"
        $securityGroupId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text
        $subnetId = aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ'].SubnetId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância EC2 de nome de tag $tagNameInstance"
        aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $securityGroupId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath\$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tagNameInstance}]" --no-cli-pager
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público da instância $tagNameInstance"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Aguardando alguns segundos para realizar a trasnferência de arquivo..."
        Start-Sleep -Seconds 45    

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o IP público da instância de nome de tag $tagNameInstance"
        $ipEc2 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text

        Write-Output "Exibindo o comando para acesso remoto via OpenSSH"
        # $ipEc2 = $ipEc2.Replace(".", "-")
        Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" ubuntu@$ipEc2"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se a pasta $awsCliFolder já existe na instância de nome de tag $tagNameInstance"
        $folderExists = ssh -i "$keyPairPath\$keyPairName.pem" -o StrictHostKeyChecking=no ubuntu@$ipEc2 "test -d \"$vmPath/$awsCliFolder\" && echo 'true' || echo 'false'"
    
        if ($folderExists -eq 'true') {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "A pasta $awsCliFolder já existe na instância de nome de tag $tagNameInstance. Transferência cancelada."
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Transferindo a pasta $awsCliFolder para a instância de nome de tag $tagNameInstance"
            scp -i "$keyPairPath\$keyPairName.pem" -o StrictHostKeyChecking=no -r "$awsCliPath\$awsCliFolder" ubuntu@${ipEc2}:${vmPath}
        }
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "EC2 EXCLUSION WITH DOCKER CONNECTED WITH ECR"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância $tagNameInstance"
    if ((aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da instância de nome de tag $tagNameInstance"
        $instanceId1 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a instância de nome de tag $tagNameInstance"
        aws ec2 terminate-instances --instance-ids $instanceId1 --no-dry-run --no-cli-pager
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    } else {Write-Output "Não existe instâncias com o nome de tag $tagNameInstance"}
} else {Write-Host "Código não executado"}