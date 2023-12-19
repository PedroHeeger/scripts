#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "LAUNCH CONFIGURATION CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$launchConfigurationName = "launchConfigurationTest1"
$amiId = "ami-0759f51a90924c166"    # Amazon Linux 2023 AMI 2023.3.20231211.4 x86_64 HVM kernel-6.1
$instanceType = "t2.micro"
$keyPair = "keyPairTest"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a configuração de inicialização de nome $launchConfigurationName"
    if ((aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?LaunchConfigurationName=='$launchConfigurationName'].LaunchConfigurationName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a configuração de inicialização de nome $launchConfigurationName"
        aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?LaunchConfigurationName=='$launchConfigurationName'].LaunchConfigurationName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as configurações de inicialiação"
        aws autoscaling describe-launch-configurations --query "LaunchConfigurations[].LaunchConfigurationName" --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um launch configuration (configuração de inicialização) de nome $launchConfigurationName"
        aws autoscaling create-launch-configuration --launch-configuration-name $launchConfigurationName --image-id $amiId --instance-type $instanceType --key-name $keyPair

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a configuração de inicialização de nome $launchConfigurationName"
        aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?LaunchConfigurationName=='$launchConfigurationName'].LaunchConfigurationName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2-AUTO SCALING"
Write-Output "LAUNCH CONFIGURATION EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$launchConfigurationName = "launchConfigurationTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a configuração de inicialização de nome $launchConfigurationName"
    if ((aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?LaunchConfigurationName=='$launchConfigurationName'].LaunchConfigurationName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as configurações de inicialiação"
        aws autoscaling describe-launch-configurations --query "LaunchConfigurations[].LaunchConfigurationName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a launch configuration (configuração de inicialização) de nome $launchConfigurationName"
        aws autoscaling delete-launch-configuration --launch-configuration-name $launchConfigurationName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as configurações de inicialiação"
        aws autoscaling describe-launch-configurations --query "LaunchConfigurations[].LaunchConfigurationName" --output text
    } else {Write-Output "Não existe a configuração de inicialização de nome $launchConfigurationName"}
} else {Write-Host "Código não executado"}