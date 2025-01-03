#!/bin/bash

echo "***********************************************"
echo "PYTHON AND PIP INSTALLATION"

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
    echo "Baixando o pacote"
    sudo apt-get install -y python3

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando o pacote"
    sudo apt-get install -y python3-pip
else 
    echo "Código não executado"
fi