#!/bin/bash

echo "***********************************************"
echo "LINUX TOOLS INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get update -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando o sistema"
    sudo apt-get upgrade -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando o pacote"
    sudo apt-get install -y nano vim curl wget unzip zip
    sudo apt-get install -y nano vim curl wget unzip zip unrar neovim aptitude net-tools iptables iputils-ping tree synaptic xman yelp build-essential
    sudo apt-get install -y nano
    sudo apt-get install -y vim
    sudo apt-get install -y curl
    sudo apt-get install -y wget
    sudo apt-get install -y unzip
    sudo apt-get install -y zip
    sudo apt-get install -y unrar
    sudo apt-get install -y neovim
    sudo apt-get install -y aptitude
    sudo apt-get install -y net-tools
    sudo apt-get install -y iptables
    sudo apt-get install -y iputils-ping
    sudo apt-get install -y tree
    sudo apt-get install -y synaptic
    sudo apt-get install -y xman
    sudo apt-get install -y yelp
    sudo apt-get install -y build-essential

    sudo apt-get install -y neovim
else 
    echo "Código não executado"
fi