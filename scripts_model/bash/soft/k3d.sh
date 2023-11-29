#!/bin/bash

echo "***********************************************"
echo "K3D INSTALLATION"

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
    echo "Baixando e executando o script de instalação"
    wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else 
    echo "Código não executado"
fi