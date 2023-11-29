#!/bin/bash

echo "***********************************************"
echo "DOCKER INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get update -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando os pacotes necessários para realizar: download seguro (SSL) (ca-certificates), operações de transferência de dados (curl), e manipulação de chaves GPG (gnupg)"
    sudo apt-get install -y ca-certificates curl gnupg

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Criando um diretório para armazenar chaves de repositórios"
    sudo install -m 0755 -d /etc/apt/keyrings

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando a chave GPG oficial do Docker, desarmazenando e salvando ela no diretório de chaves (com o Gnupg)"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Garantindo que a chave GPG do Docker tenha as permissões corretas"
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionando o repositório do Docker à lista de fontes de pacotes do sistema"
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$UBUNTU_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get update -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando os pacotes principais do Docker, incluindo o Docker Community Edition, o daemon (dockerd), a CLI (docker), o containerd (motor de execução de contêineres), e plugins adicionais (Docker Buildx e Docker Compose)."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else 
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "DOCKER CONFIGURATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
username="ubuntu"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionando o usuário ao grupo do Docker"
    sudo usermod -aG docker ${username}

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Confirmando as alterações realizadas no grupo"
    sudo newgrp docker
else 
    echo "Código não executado"
fi