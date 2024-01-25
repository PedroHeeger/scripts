#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "EC2 CONTAINER INSTANCE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2ContainerInstanceTest"
$instanceA = "5"
$instanceB = "6"
$sgName = "default"
$aZ = "us-east-1a"
$imageId = "ami-079db87dc4c10ac91"    # Amazon Linux 2023 AMI 2023.3.20231218.0 x86_64 HVM kernel-6.1
$instanceType = "t2.micro"
$keyPairName = "keyPairUniversal"
$instanceProfileName = "ecs-ec2InstanceIProfile"
$clusterName = "clusterEC2Test1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    $condition = aws ec2 describe-instances --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceA}' || Value=='${tagNameInstance}${instanceB}')])].[Tags[?Key=='Name'].Value | [0]]" --output text
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe as instâncias ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe uma instância EC2 com o nome de tag ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceA}'].Value" --output text
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceB}'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público das instâncias ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
        aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os Ids do grupo de segurança e das sub-redes padrões"
        $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text
        $subnetId = aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ'].SubnetId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância EC2 de nome de tag ${tagNameInstance}${instanceA}"
        aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $sgId --subnet-id $subnetId --count 1 --user-data "#!/bin/bash
        echo 'EXECUTANDO O SCRIPT BASH'
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Atualizando os pacotes'
        sudo yum update -y
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Atualizando o sistema'
        sudo yum upgrade -y
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Criando o diretório do ECS'        
        sudo mkdir -p /etc/ecs
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Criando o diretório do ECS'  
        echo 'ECS_CLUSTER=$clusterName' | sudo tee -a /etc/ecs/ecs.config
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Aguardando alguns segundos (TEMPO 1)'  
        sleep 20
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Instalando o agente do ECS'  
        sudo yum install -y ecs-init
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Aguardando alguns segundos (TEMPO 2)'
        sleep 60
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Habilitando o ECS'  
        sudo systemctl enable ecs
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Aguardando alguns segundos (TEMPO 3)'  
        sleep 60
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Reiniciando o sistema'  
        sudo reboot" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${tagNameInstance}${instanceA}}]" --iam-instance-profile "Name=$instanceProfileName" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância EC2 de nome de tag ${tagNameInstance}${instanceB}"
        aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $keyPairName --security-group-ids $sgId --subnet-id $subnetId --count 1 --user-data "#!/bin/bash
        echo 'EXECUTANDO O SCRIPT BASH'
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Atualizando os pacotes'
        sudo yum update -y
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Atualizando o sistema'
        sudo yum upgrade -y
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Criando o diretório do ECS'        
        sudo mkdir -p /etc/ecs
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Criando o diretório do ECS'  
        echo 'ECS_CLUSTER=$clusterName' | sudo tee -a /etc/ecs/ecs.config
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Aguardando alguns segundos (TEMPO 1)'  
        sleep 20
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Instalando o agente do ECS'  
        sudo yum install -y ecs-init
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Aguardando alguns segundos (TEMPO 2)'
        sleep 60
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Habilitando o ECS'  
        sudo systemctl enable ecs
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Aguardando alguns segundos (TEMPO 3)'  
        sleep 60
        echo '-----//-----//-----//-----//-----//-----//-----'
        echo 'Reiniciando o sistema'  
        sudo reboot" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${tagNameInstance}${instanceB}}]" --iam-instance-profile "Name=$instanceProfileName" --no-cli-pager
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o IP público das instâncias ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
        aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "EC2 CONTAINER INSTANCE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2ContainerInstanceTest"
$instanceA = "5"
$instanceB = "6"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    $condition = aws ec2 describe-instances --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceA}' || Value=='${tagNameInstance}${instance}2')])].[Tags[?Key=='Name'].Value | [0]]" --output text
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe as instâncias ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
    if (($condition).Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id das instâncias de nome de tag ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        $instanceId1 = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" --query "Reservations[].Instances[].InstanceId" --output text
        $instanceId2 = aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" --query "Reservations[].Instances[].InstanceId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo as instâncias de nome de tag ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 terminate-instances --instance-ids $instanceId1 $instanceId2 --no-dry-run --no-cli-pager
        
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o nome da tag de todas as instâncias EC2 criadas"
        aws ec2 describe-instances --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    } else {Write-Output "Não existe instâncias com o nome de tag ${tagNameInstance}${instanceA} ou ${tagNameInstance}${instanceB}"}
} else {Write-Host "Código não executado"}