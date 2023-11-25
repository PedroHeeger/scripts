#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "KEY PAIR CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
keyPairName="keyPair1"
keyPairPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\power_shell\aws/"  # path

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o par de chaves $keyPairName"
    if [[ $(aws ec2 describe-key-pairs --query "KeyPairs[?KeyName=='$keyPairName']" --output json | jq length) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "O par de chaves $keyPairName já foi criado!"
        aws ec2 describe-key-pairs --query "KeyPairs[?KeyName=='$keyPairName'].KeyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os pares de chaves criados"
        aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o par de chaves $keyPairName"
        aws ec2 create-key-pair --key-name "$keyPairName" --query 'KeyMaterial' --output text > "$keyPairPath/$keyPairName.pem"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando apenas o par de chave $keyPairName"
        aws ec2 describe-key-pairs --query "KeyPairs[?KeyName=='$keyPairName'].KeyName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "KEY PAIR EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
keyPairName="keyPair1"
keyPairPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\power_shell\aws/"  # path

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" == 'y' ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o par de chaves $keyPairName"
    if aws ec2 describe-key-pairs --query "KeyPairs[?KeyName=='$keyPairName']" --output json | grep -q "$keyPairName"; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o par de chaves criado de nome $keyPairName e os arquivos pem e ppk"
        aws ec2 delete-key-pair --key-name "$keyPairName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o arquivo de par de chaves $keyPairName.pem"
        if [ -e "$keyPairPath/$keyPairName.pem" ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o arquivo de par de chave $keyPairName.pem"
            rm "$keyPairPath/$keyPairName.pem"
        else
            echo "Não existe o arquivo de par de chave $keyPairName.pem"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o arquivo de par de chaves $keyPairName.ppk"
        if [ -e "$keyPairPath/$keyPairName.ppk" ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o arquivo de par de chave $keyPairName.ppk"
            rm "$keyPairPath/$keyPairName.ppk"
        else
            echo "Não existe o arquivo de par de chave $keyPairName.ppk"
        fi
    else
        echo "Não existe o par de chaves de nome $keyPairName!"
    fi
else
    echo "Código não executado"
fi
