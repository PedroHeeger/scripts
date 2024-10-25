#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "KEY PAIR CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
keyPairName="keyPairTest"
keyPairPath="G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/test"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o par de chaves de nome $keyPairName"
    condition=$(aws ec2 describe-key-pairs --output text | grep "$keyPairName" | wc -l)
    if [[ $condition -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o par de chaves de nome $keyPairName"
        aws ec2 describe-key-pairs --query "KeyPairs[?KeyName=='$keyPairName'].KeyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os pares de chaves criados"
        aws ec2 describe-key-pairs --query "KeyPairs[].KeyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o par de chaves de nome $keyPairName e salvado o arquivo de chave privada"
        aws ec2 create-key-pair --key-name "$keyPairName" --query 'KeyMaterial' --output text > "$keyPairPath/$keyPairName.pem"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando apenas o par de chave de nome $keyPairName"
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
keyPairName="keyPairTest"
keyPairPath="G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/test"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" == 'y' ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o par de chaves de nome $keyPairName"
    condition=$(aws ec2 describe-key-pairs --output text | grep "$keyPairName" | wc -l)
    if [[ $condition -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os pares de chaves criados"
        aws ec2 describe-key-pairs --query "KeyPairs[].KeyName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o par de chaves de nome $keyPairName"
        aws ec2 delete-key-pair --key-name "$keyPairName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o arquivo de chave privada de nome $keyPairName.pem"
        if [ -e "$keyPairPath/$keyPairName.pem" ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o arquivo de chave privada de nome $keyPairName.pem"
            rm "$keyPairPath/$keyPairName.pem"
        else
            echo "Não existe o arquivo de chave privada de nome $keyPairName.pem"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o arquivo de chave privada de nome $keyPairName.ppk"
        if [ -e "$keyPairPath/$keyPairName.ppk" ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o arquivo de chave privada de nome $keyPairName.ppk"
            rm "$keyPairPath/$keyPairName.ppk"
        else
            echo "Não existe o arquivo de chave privada de nome $keyPairName.ppk"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os pares de chaves criados"
        aws ec2 describe-key-pairs --query "KeyPairs[].KeyName" --output text
    else
        echo "Não existe o par de chaves de nome $keyPairName"
    fi
else
    echo "Código não executado"
fi