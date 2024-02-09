#!/bin/bash

echo "***********************************************"
echo "MYSQL SERVER INSTALLATION"

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
    echo "Instalando o pacote server"
    sudo apt-get install -y mysql-server

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote client"
    sudo apt-get install -y mysql-client
else 
    echo "Código não executado"
fi