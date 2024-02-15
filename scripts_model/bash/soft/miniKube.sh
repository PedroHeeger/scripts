#!/bin/bash

echo "***********************************************"
echo "MINIKUBE INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
link="https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando o pacote"
    curl -LO $link

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote"
    sudo dpkg -i minikube_latest_amd64.deb
else 
    echo "Código não executado"
fi