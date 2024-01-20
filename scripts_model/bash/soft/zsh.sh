#!/bin/bash

echo "***********************************************"
echo "ZSHELL INSTALLATION"

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
    sudo apt-get install -y zsh

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Alterando o Shell padrão do usuário ubuntu"
    sudo chsh -s /usr/bin/zsh ubuntu

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Indicando que esse Shell deve ser iniciado"
    echo "zsh" >> /home/ubuntu/.bashrc
else 
    echo "Código não executado"
fi





#!/bin/bash

echo "***********************************************"
echo "OH MY ZSHELL INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
HOME="/home/ubuntu"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Baixando o script de instalação"
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o oh-my-zsh-install.sh

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Executando o srcipt de instalação"
    sh oh-my-zsh-install.sh --unattended --path=$HOME

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Removendo o srcipt de instalação do Oh My ZShell"
    rm oh-my-zsh-install.sh
else 
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "POWER LEVEL PLUGIN"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
HOME="/home/ubuntu"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Clonando o repositório para a pasta do Oh My Zsh"
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionando o comando typeset no arquivo de configuração do Zsh"
    sudo echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=off" | sudo -E tee -a ${ZDOTDIR:-$HOME}/.zshrc

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o arquivo de configuração do Zsh"
    rc_file="$HOME/.zshrc"
    if [ -f "$rc_file" ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Fazendo a alteração do tema no arquivo de configuração do Zsh"
        sed -i 's#ZSH_THEME=.*#ZSH_THEME="powerlevel10k/powerlevel10k"#' $HOME/.zshrc
    else
        echo "O arquivo $rc_file não existe."
    fi
else 
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "AUTO SUGGESTIONS PLUGIN"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
HOME="/home/ubuntu"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Definindo o caminho personalizado para o plugin"
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Clonando o repositório para caminho personalizado"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionando o caminho deste arquivo no arquivo de configuração do Zsh"
    echo "source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" | sudo -E tee -a ${ZDOTDIR:-$HOME}/.zshrc
else 
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SYNTAX HIGHLIGHTING PLUGIN"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
HOME="/home/ubuntu"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Definindo o caminho personalizado para o plugin"
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Clonando o repositório para caminho personalizado"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Adicionando o caminho deste arquivo no arquivo de configuração do Zsh"
    echo "source ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" | sudo -E tee -a ${ZDOTDIR:-$HOME}/.zshrc
else 
    echo "Código não executado"
fi