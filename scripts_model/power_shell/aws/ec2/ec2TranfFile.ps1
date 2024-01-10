#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "EC2 TRANSFER FILES"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$tagNameInstance = "ec2Test1"
$keyPairPath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awsKeyPair"
$keyPairName = "keyPairUniversal"
$awsCliPath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awscli/iamUserWorker"
$awsCliFolder = ".aws"
$dockerPath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets"
$dockerFolder = ".docker"
$vmPath = "/home/ubuntu"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância $tagNameInstance"
    if ((aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[]").Count -gt 1) {       
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o IP público da instância de nome de tag $tagNameInstance"
        $ipEc2 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$tagNameInstance" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text

        Write-Output "Exibindo o comando para acesso remoto via OpenSSH"
        # $ipEc2 = $ipEc2.Replace(".", "-")
        Write-Output "ssh -i `"$keyPairPath\$keyPairName.pem`" ubuntu@$ipEc2"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se a pasta $awsCliFolder já existe na instância de nome de tag $tagNameInstance"
        $folderExists = ssh -i "$keyPairPath\$keyPairName.pem" -o StrictHostKeyChecking=no ubuntu@$ipEc2 "test -d `"$vmPath/$awsCliFolder`" && echo 'true' || echo 'false'"
    
        if ($folderExists -eq 'true') {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "A pasta $awsCliFolder já existe na instância de nome de tag $tagNameInstance. Transferência cancelada."
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Transferindo a pasta $awsCliFolder para a instância de nome de tag $tagNameInstance"
            scp -i "$keyPairPath\$keyPairName.pem" -o StrictHostKeyChecking=no -r "$awsCliPath\$awsCliFolder" ubuntu@${ipEc2}:${vmPath}
        }

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se a pasta $dockerFolder já existe na instância de nome de tag $tagNameInstance"
        $folderExists = ssh -i "$keyPairPath\$keyPairName.pem" -o StrictHostKeyChecking=no ubuntu@$ipEc2 "test -d `"$vmPath/$dockerFolder`" && echo 'true' || echo 'false'"
    
        if ($folderExists -eq 'true') {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "A pasta $dockerFolder já existe na instância de nome de tag $tagNameInstance. Transferência cancelada."
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Transferindo a pasta $dockerFolder para a instância de nome de tag $tagNameInstance"
            scp -i "$keyPairPath\$keyPairName.pem" -o StrictHostKeyChecking=no -r "$dockerPath\$dockerFolder" ubuntu@${ipEc2}:${vmPath}
        }
    } else {"Não existe instâncias com o nome de tag $tagNameInstance"}
} else {Write-Host "Código não executado"}