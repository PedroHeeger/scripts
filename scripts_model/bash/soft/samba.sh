#!/bin/bash

echo "***********************************************"
echo "SAMBA INSTALLATION"

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
    sudo apt-get install -y samba

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Reiniciando o serviço"
    sudo systemctl restart smbd

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Habilitando o serviço para que seja executado automaticamente"
    sudo systemctl enable smbd
else 
    echo "Código não executado"
fi