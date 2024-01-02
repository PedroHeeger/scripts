#!/bin/bash

echo "Arquivo de Teste"

echo "***********************************************"
echo "APACHE HTTP (HTTPD) INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Atualizando os pacotes"
sudo apt-get update -y

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Atualizando o sistema"
sudo apt-get upgrade -y

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Instalando o pacote"
sudo apt-get install -y apache2

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Reiniciando o serviço"
sudo systemctl restart apache2

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Habilitando o serviço para que seja executado automaticamente"