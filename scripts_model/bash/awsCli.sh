#!/bin/bash

echo "***********************************************"
echo "AWS CLI INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando o pacote"
    curl "$link" -o "awscliv2.zip"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Descompactando o pacote"
    unzip awscliv2.zip

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote"
    sudo ./aws/install
else 
    echo "Código não executado"
fi





