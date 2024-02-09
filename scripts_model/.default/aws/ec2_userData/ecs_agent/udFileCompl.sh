#!/bin/bash
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
echo "ECS_CLUSTER=${var.clusterName}" | sudo tee -a /etc/ecs/ecs.config

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
sudo reboot