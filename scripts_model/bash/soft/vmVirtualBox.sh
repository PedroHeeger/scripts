#!/bin/bash

echo "***********************************************"
echo "ORACLE VM VIRTUAL BOX INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get update -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote"
    sudo apt install -y virtualbox virtualbox-ext-pack

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionando o usuário ao grupo"
    sudo usermod -aG vboxusers $USER
else 
    echo "Código não executado"
fi