#!/bin/bash

echo "***********************************************"
echo "AWS CLI INSTALLATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
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




#!/bin/bash

echo "***********************************************"
echo "AWS CLI CONFIGURATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
accessKey="SEU_ACCESS_KEY"
secretKey="SEU_SECRET_KEY"
region="us-east-1"
outputFormat="json"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Configurando as credenciais"
    aws configure set aws_access_key_id "$accessKey"
    aws configure set aws_secret_access_key "$secretKey"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Configurando a região e o formato de saída dos dados"
    aws configure set default.region "$region"
    aws configure set default.output "$outputFormat"
else
    echo "Código não executado"
fi