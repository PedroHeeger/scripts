#!/bin/bash

echo "***********************************************"
echo "LINUX TOOLS INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Atualizando os pacotes"
sudo apt-get update -y

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Atualizando o sistema"
sudo apt-get upgrade -y

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Baixando o pacote"
sudo apt-get install -y nano vim curl wget unzip zip git




echo "-----//-----//-----//-----//-----//-----//-----"
echo "Instalando o NVM"
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Baixando e instalando o Node.js com NPM"
sudo nvm install 22