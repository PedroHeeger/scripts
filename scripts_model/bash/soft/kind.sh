#!/bin/bash

echo "***********************************************"
echo "KIND INSTALLATION"

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
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Alterando a permissão da pasta do repositório"
    sudo chmod +x ./kind

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Movendo a pasta do pacote para a pasta criada"
    sudo mv ./kind /usr/local/bin/kind
else 
    echo "Código não executado"
fi