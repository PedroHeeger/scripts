#!/bin/bash

echo "***********************************************"
echo "KUBECTL INSTALLATION"

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
    echo "Instalando os pacotes de dependência"
    sudo apt-get install -y apt-transport-https ca-certificates curl

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Criando um diretório para armazenar chaves de repositórios"
    sudo install -m 0755 -d /etc/apt/keyrings

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando a chave de assinatura pública para os repositórios de pacotes Kubernetes"
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionando o repositório do pacote à lista de fontes de pacotes do sistema"
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Atualizando os pacotes"
    sudo apt-get update -y

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Instalando o pacote"
    sudo apt-get install -y kubectl

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Exibindo a versão"
    kubectl version --client
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