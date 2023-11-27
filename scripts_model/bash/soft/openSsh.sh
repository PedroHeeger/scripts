#!/bin/bash

echo "***********************************************"
echo "OPENSSH INSTALLATION"

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
    echo "Instalando o servidor ssh (sshd)"
    sudo apt-get install -y openssh-server

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o cliente ssh"
    sudo apt-get install -y ssh

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Reiniciando o serviço"
    systemctl restart ssh
else 
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "OPENSSH CREATION KEY"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
keyPairName="keyPairTest"
keyPairPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\bash\.default\secrets"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Criando uma chave com senha vazia e gerando os arquivos .pub (pública) e .pem (privada)"
    ssh-keygen -t rsa -b 2048 -N "" -f "$keyPairPath/$keyPairName.pem"
else
    echo "Código não executado"
fi