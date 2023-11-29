#!/bin/bash

echo "***********************************************"
echo "POSTGRESQL INSTALLATION"

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
    echo "Definindo a versão"
    version="version"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote na versão determinada"
    sudo apt-get install -y postgresql-$version

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote cliente na versão determinada"
    sudo apt-get install -y postgresql-client-$version
else 
    echo "Código não executado"
fi