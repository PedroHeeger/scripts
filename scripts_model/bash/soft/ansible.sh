#!/bin/bash

echo "***********************************************"
echo "ANSIBLE INSTALLATION"

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
    sudo apt-get install -y ansible

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionado a permissão de execução"
    sudo chmod +x install_ansible.sh

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote"
    sudo ./install_ansible.sh
else 
    echo "Código não executado"
fi