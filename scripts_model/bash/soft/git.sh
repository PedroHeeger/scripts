#!/bin/bash

echo "***********************************************"
echo "GIT INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get update -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando o sistema"
    sudo apt-get upgrade -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote"
    sudo apt-get install -y git
else 
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "GIT CONFIGURATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
userName="PedroHeeger"
userEmail="pedroheeger19@gmail.com"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Configurando o nome de usuário"
    git config --global user.name "$userName"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Configurando o email do usuário"
    git config --global user.email "$userEmail"
else
    echo "Código não executado"
fi