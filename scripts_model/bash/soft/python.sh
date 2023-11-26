#!/bin/bash

echo "***********************************************"
echo "PYTHON AND PIP INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get -y update

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando o sistema"
    sudo apt-get -y upgrade

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando o pacote"
    sudo apt-get install -y python3

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando o pacote"
    sudo apt-get install -y python3-pip
else 
    echo "Código não executado"
fi