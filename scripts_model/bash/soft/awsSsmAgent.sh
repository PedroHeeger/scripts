#!/bin/bash

echo "***********************************************"
echo "AWS SSM Agent INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get update -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando o sistema"
    sudo apt-get upgrade -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote"
    sudo apt-get install -y amazon-ssm-agent

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Iniciando o serviço"
    sudo systemctl start amazon-ssm-agent

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Habilitando o serviço"
    sudo systemctl enable amazon-ssm-agent
else 
    echo "Código não executado"
fi