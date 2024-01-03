#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "EC2 INSTANCE 1 CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance2 = "ec2Test2"
$groupName = "default"
$availabilityZone = "us-east-1a"
$imageId = "ami-0fc5d935ebf8bc3bc"
$instanceType = "t2.micro"
$keyPairName = "keyPairTest"
$userDataPath = "G:\Meu Drive\4_PROJ\scripts\scripts_model\power_shell\aws\elb\suport\"
$userDataFile = "udFileTest.sh"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância $tagNameInstance2"
    if ((aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe uma instância EC2 com o nome de tag $tagNameInstance2"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='$tagNameInstance2'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público da instância $tagNameInstance2"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os Ids do grupo de segurança e sub-redes padrões"
        $securityGroupId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text
        $subnetId = aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$availabilityZone'].SubnetId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância EC2 de nome de tag $tagNameInstance2"
        aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $securityGroupId --subnet-id $subnetId --count 1 --user-data "file://$userDataPath\$userDataFile" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tagNameInstance2}]" --no-cli-pager
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público da instância $tagNameInstance2"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "EC2 EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance2 = "ec2Test2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância $tagNameInstance2"
    if ((aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id da instância de nome de tag $tagNameInstance2"
        $instanceId1 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance2" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a instância de nome de tag $tagNameInstance2"
        aws ec2 terminate-instances --instance-ids $instanceId1 --no-dry-run --no-cli-pager
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    } else {Write-Output "Não existe instâncias com o nome de tag $tagNameInstance2"}
} else {Write-Host "Código não executado"}